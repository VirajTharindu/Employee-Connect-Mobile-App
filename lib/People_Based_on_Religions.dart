import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class PeopleBasedOnReligionsScreen extends StatefulWidget {
  const PeopleBasedOnReligionsScreen({super.key});

  @override
  _PeopleBasedOnReligionsScreenState createState() =>
      _PeopleBasedOnReligionsScreenState();
}

class _PeopleBasedOnReligionsScreenState
    extends State<PeopleBasedOnReligionsScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedReligions = {};

  @override
  void initState() {
    super.initState();
    _fetchReligionFamilyMembers();
  }

  Future<void> _fetchReligionFamilyMembers() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryReligionFamilyMembers();

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Clear previous data
    groupedReligions.clear();

    for (var familyMember in allFamilyMembers) {
      String religion = familyMember.religion; // Handle null case
      String householdNumber = familyMember.householdNumber;

      // Group by religion, then by household number
      if (!groupedReligions.containsKey(religion)) {
        groupedReligions[religion] = {};
      }

      if (groupedReligions[religion]!.containsKey(householdNumber)) {
        groupedReligions[religion]![householdNumber]!.add(familyMember);
      } else {
        groupedReligions[religion]![householdNumber] = [familyMember];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  // New method to generate PDF
  Future<void> generatePdf() async {
    // Flatten all members from grouped religions
    final List<FamilyMember> members = groupedReligions.values
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
                    "People Based on Religions - Village Officer App",
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
                        "Total Households: ${groupedReligions.values.fold(0, (total, householdMap) => total + householdMap.keys.length)}",
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
                    children: groupedReligions.entries
                        .map((religionEntry) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Text(
                                    religionEntry.key,
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
                                    "${religionEntry.value.values.fold(0, (total, members) => total + members.length)}",
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
              itemCount: groupedReligions.length,
              itemBuilder: (context, religionIndex) {
                final religion = groupedReligions.keys.toList()[religionIndex];
                final religionMap = groupedReligions[religion]!;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 15),
                    pw.Text(
                      "$religion Religion",
                      style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 16,
                          color: PdfColors.green900),
                    ),
                    pw.SizedBox(height: 10),
                    pw.ListView.builder(
                      itemCount: religionMap.keys.length,
                      itemBuilder: (context, householdIndex) {
                        final householdNumber =
                            religionMap.keys.toList()[householdIndex];
                        final householdMembers = religionMap[householdNumber]!;

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
                                            textAlign: pw.TextAlign.center),
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
                                                pw.Text(
                                                  member.dateOfModified,
                                                  style: pw.TextStyle(
                                                      font: ttfRegular,
                                                      fontSize: 9),
                                                )
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
          "People_Based_on_Religions_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
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

  // Define the ordered list of religions as specified
  final List<String> _orderedReligions = [
    'Buddhism',
    'Hinduism',
    'Islam',
    'Christianity',
    'Other',
  ];

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
    // Calculate the total number of families and members
    int totalFamilies = 0;
    int totalMembers = 0;
    groupedReligions.forEach((religion, households) {
      households.forEach((householdNumber, members) {
        totalFamilies++;
        totalMembers += members.length;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('People Based on Religions'),
            Text(
              '$totalFamilies ${totalFamilies == 1 ? "Family" : "Families"} | $totalMembers ${totalMembers == 1 ? "Family Member" : "Family Members"}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
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
      body: ListView.builder(
        itemCount: _orderedReligions.length,
        itemBuilder: (context, index) {
          String religion = _orderedReligions[index];
          Map<String, List<FamilyMember>> householdMap =
              groupedReligions[religion] ?? {};

          // Show a placeholder if no household members are found for this religion
          if (householdMap.isEmpty) {
            return ListTile(
              title: Text(
                religion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("No members found for this religion"),
            );
          }

          // Display the households grouped by religion
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text(religion),
              subtitle: Text('Households: ${householdMap.keys.length}'),
              children:
                  householdMap.entries.toList().asMap().entries.map((entry) {
                int householdIndex =
                    entry.key + 1; // Numbering household numbers
                MapEntry<String, List<FamilyMember>> entryValue = entry.value;
                String householdNumber = entryValue.key;
                List<FamilyMember> members = entryValue.value;

                return ExpansionTile(
                  title: Text(
                    '${householdMap.keys.toList().indexOf(householdNumber) + 1}. Household Number: $householdNumber',
                  ),
                  subtitle: Text('Members: ${members.length}'),
                  children: members.asMap().entries.map((entry) {
                    int memberIndex = entry.key + 1; // Numbering family members
                    FamilyMember member = entry.value;

                    return ListTile(
                      title: Text(
                        '${getOrdinal(memberIndex)}: ${member.name}',
                      ),
                      subtitle: Text(
                        'National ID: ${member.nationalId}',
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
