import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'family_member.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'database_helper.dart';

class PeopleBasedOnAgeGroups extends StatefulWidget {
  const PeopleBasedOnAgeGroups({super.key});

  @override
  _PeopleBasedOnAgeGroupsState createState() => _PeopleBasedOnAgeGroupsState();
}

class _PeopleBasedOnAgeGroupsState extends State<PeopleBasedOnAgeGroups> {
  late Future<Map<String, Map<String, List<FamilyMember>>>> ageGroupsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch age groups data grouped by household number
    ageGroupsFuture = _fetchAgeGroupedFamilyMembers();
  }

  Future<Map<String, Map<String, List<FamilyMember>>>>
      _fetchAgeGroupedFamilyMembers() async {
    final ageGroups = await DatabaseHelper.instance.getPeopleBasedOnAgeGroups();

    // Group by household number within each age group
    Map<String, Map<String, List<FamilyMember>>> groupedAgeGroups = {};

    for (var ageGroup in ageGroups.keys) {
      groupedAgeGroups[ageGroup] = {};

      for (var member in ageGroups[ageGroup]!) {
        String householdNumber = member.householdNumber;

        if (!groupedAgeGroups[ageGroup]!.containsKey(householdNumber)) {
          groupedAgeGroups[ageGroup]![householdNumber] = [];
        }
        groupedAgeGroups[ageGroup]![householdNumber]!.add(member);
      }
    }

    return groupedAgeGroups;
  }

  // New method to generate PDF
  Future<void> generatePdf() async {
    // Wait for the future to complete
    final ageGroups = await ageGroupsFuture;

    // Flatten all members from grouped age groups
    final List<FamilyMember> members = ageGroups.values
        .expand((householdMap) => householdMap.values)
        .expand((householdMembers) => householdMembers)
        .toList();

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Family Members found to generate PDF'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pdf = pw.Document();

    // Load fonts
    final regularFont =
        await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFont = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttfRegular = pw.Font.ttf(regularFont);
    final ttfBold = pw.Font.ttf(boldFont);

    // Get current date
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day}/${currentDate.month}/${currentDate.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) {
          return pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColors.green100,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.green300, width: 2),
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "People Based on Age Groups - Village Officer App",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 16, color: PdfColors.green900),
                  ),
                  pw.Text(
                    "Generated: $formattedDate",
                    style: pw.TextStyle(
                        font: ttfRegular,
                        fontSize: 10,
                        color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(font: ttfRegular, fontSize: 10),
            ),
          );
        },
        build: (context) {
          int totalFamilies = ageGroups.values.fold(0, (total, householdMap) {
            return total + householdMap.keys.length;
          });

          return [
            // Summary Statistics
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Total Households: $totalFamilies",
                        style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                            color: PdfColors.green900),
                      ),
                      pw.Text(
                        "Total Family Members: ${members.length}",
                        style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                            color: PdfColors.green900),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: ageGroups.entries
                        .map((ageEntry) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Text(
                                    ageEntry.key,
                                    style: pw.TextStyle(
                                        font: ttfRegular,
                                        fontSize: 10,
                                        color: PdfColors.grey700),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Text(
                                    "${ageEntry.value.values.fold(0, (total, members) => total + members.length)}",
                                    style: pw.TextStyle(
                                        font: ttfBold,
                                        fontSize: 10,
                                        color: PdfColors.green900),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Detailed Household Information
            pw.ListView.builder(
              itemCount: ageGroups.length,
              itemBuilder: (context, ageIndex) {
                final ageGroup = ageGroups.keys.toList()[ageIndex];
                final ageGroupMap = ageGroups[ageGroup]!;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 15),
                    pw.Text(
                      ageGroup,
                      style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 16,
                          color: PdfColors.green900),
                    ),
                    pw.SizedBox(height: 10),
                    pw.ListView.builder(
                      itemCount: ageGroupMap.keys.length,
                      itemBuilder: (context, householdIndex) {
                        final householdNumber =
                            ageGroupMap.keys.toList()[householdIndex];
                        final householdMembers = ageGroupMap[householdNumber]!;

                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 15),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.green100, width: 1),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      "${householdIndex + 1}. ",
                                      style: pw.TextStyle(
                                        font: ttfBold,
                                        fontSize: 16,
                                        color: PdfColors.green900,
                                      ),
                                    ),
                                    pw.Text(
                                      "Household Number: $householdNumber",
                                      style: pw.TextStyle(
                                        font: ttfBold,
                                        fontSize: 14,
                                        color: PdfColors.green900,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  "Total Members: ${householdMembers.length}",
                                  style: pw.TextStyle(
                                      font: ttfRegular,
                                      fontSize: 12,
                                      color: PdfColors.grey700),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Table(
                                  border: pw.TableBorder.all(
                                      color: PdfColors.green100, width: 1),
                                  columnWidths: {
                                    0: const pw.FlexColumnWidth(3),
                                    1: const pw.FlexColumnWidth(2),
                                    2: const pw.FlexColumnWidth(2),
                                    3: const pw.FlexColumnWidth(2),
                                    4: const pw.FlexColumnWidth(3),
                                  },
                                  children: [
                                    // Table Header
                                    pw.TableRow(
                                      decoration: const pw.BoxDecoration(
                                          color: PdfColors.green50),
                                      children: [
                                        pw.Text("Family Head Type",
                                            style: pw.TextStyle(
                                                font: ttfBold,
                                                fontSize: 10,
                                                color: PdfColors.green900),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("Name",
                                            style: pw.TextStyle(
                                                font: ttfBold,
                                                fontSize: 10,
                                                color: PdfColors.green900),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("National ID",
                                            style: pw.TextStyle(
                                                font: ttfBold,
                                                fontSize: 10,
                                                color: PdfColors.green900),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("Age",
                                            style: pw.TextStyle(
                                                font: ttfBold,
                                                fontSize: 10,
                                                color: PdfColors.green900),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("Date of Modified",
                                            style: pw.TextStyle(
                                                font: ttfBold,
                                                fontSize: 10,
                                                color: PdfColors.green900),
                                            textAlign: pw.TextAlign.center)
                                      ],
                                    ),
                                    // Table Rows
                                    ...householdMembers
                                        .map((member) => pw.TableRow(
                                              decoration: pw.BoxDecoration(
                                                  color:
                                                      householdMembers.indexOf(
                                                                      member) %
                                                                  2 ==
                                                              0
                                                          ? PdfColors.white
                                                          : PdfColors.green50),
                                              children: [
                                                pw.Text(member.familyHeadType,
                                                    style: pw.TextStyle(
                                                        font: ttfRegular,
                                                        fontSize: 9),
                                                    textAlign:
                                                        pw.TextAlign.center),
                                                pw.Text(member.name,
                                                    style: pw.TextStyle(
                                                        font: ttfRegular,
                                                        fontSize: 9),
                                                    textAlign:
                                                        pw.TextAlign.center),
                                                pw.Text(
                                                    member.nationalId ?? 'N/A',
                                                    style: pw.TextStyle(
                                                        font: ttfRegular,
                                                        fontSize: 9),
                                                    textAlign:
                                                        pw.TextAlign.center),
                                                pw.Text(member.age.toString(),
                                                    style: pw.TextStyle(
                                                        font: ttfRegular,
                                                        fontSize: 9),
                                                    textAlign:
                                                        pw.TextAlign.center),
                                                pw.Text(member.dateOfModified,
                                                    style: pw.TextStyle(
                                                        font: ttfRegular,
                                                        fontSize: 9),
                                                    textAlign:
                                                        pw.TextAlign.center)
                                              ],
                                            ))
                                        .toList(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ];
        },
      ),
    );

    // Save the PDF and print it
    try {
      final tempDir = await getTemporaryDirectory();
      final currentDate = DateTime.now();
      final fileName =
          "People_Based_on_Age_Groups_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
      final pdfFile = File("${tempDir.path}/$fileName");

      // Save the PDF file
      final pdfBytes = await pdf.save();
      await pdfFile.writeAsBytes(pdfBytes);

      // Display print preview
      final printResult = await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );

      // Check if the print/download was actually completed
      if (printResult == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF downloaded successfully as $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors with appropriate checks
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getOrdinal(int number) {
    if (number <= 0) return number.toString();
    switch (number % 10) {
      case 1:
        return (number % 100 == 11) ? '${number}th' : '${number}st';
      case 2:
        return (number % 100 == 12) ? '${number}th' : '${number}nd';
      case 3:
        return (number % 100 == 13) ? '${number}th' : '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('People Based on Age Groups'),
            FutureBuilder<Map<String, Map<String, List<FamilyMember>>>>(
              future: ageGroupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('');
                } else {
                  final ageGroups = snapshot.data!;
                  int familyCount = 0;
                  int memberCount = 0;
                  ageGroups.forEach((ageGroup, householdMap) {
                    familyCount += householdMap.keys.length;
                    householdMap.forEach((_, members) {
                      memberCount += members.length;
                    });
                  });

                  return Text(
                    '$familyCount ${familyCount == 1 ? "Family" : "Families"} | $memberCount ${memberCount == 1 ? "Family Member" : "Family Members"}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: generatePdf,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, Map<String, List<FamilyMember>>>>(
        future: ageGroupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final ageGroups = snapshot.data!;

          return ListView.builder(
            itemCount: ageGroups.keys.length,
            itemBuilder: (context, index) {
              final ageGroup = ageGroups.keys.elementAt(index);
              final householdMap = ageGroups[ageGroup]!;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: householdMap.isEmpty
                    ? ListTile(
                        title: Text(
                          ageGroup,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            const Text("No members found for this age group"),
                      )
                    : ExpansionTile(
                        title: Text(ageGroup),
                        subtitle:
                            Text('Households: ${householdMap.keys.length}'),
                        children: householdMap.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          int householdIndex = entry.key + 1;
                          MapEntry<String, List<FamilyMember>> entryValue =
                              entry.value;
                          String householdNumber = entryValue.key;
                          List<FamilyMember> members = entryValue.value;

                          return ExpansionTile(
                            title: Text(
                                '$householdIndex. Household Number: $householdNumber'),
                            subtitle: Text('Members: ${members.length}'),
                            children: members.asMap().entries.map((entry) {
                              int memberIndex = entry.key + 1;
                              FamilyMember member = entry.value;

                              return ListTile(
                                title: Text(
                                    '${getOrdinal(memberIndex)}: ${member.name}'),
                                subtitle: Text(
                                    'National ID: ${member.nationalId} | Age: ${member.age}'),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
