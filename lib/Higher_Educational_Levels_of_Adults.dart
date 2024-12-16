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

class HigherEducationalLevelsOfAdultsScreen extends StatefulWidget {
  @override
  _HigherEducationalLevelsOfAdultsScreenState createState() =>
      _HigherEducationalLevelsOfAdultsScreenState();
}

class _HigherEducationalLevelsOfAdultsScreenState
    extends State<HigherEducationalLevelsOfAdultsScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedEducationLevels = {};

  @override
  void initState() {
    super.initState();
    _fetchHigherEducationLevels();
  }

  Future<void> _fetchHigherEducationLevels() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryHigherEducationFamilyMembers();

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Clear previous data
    groupedEducationLevels.clear();

    for (var familyMember in allFamilyMembers) {
      String educationLevel = familyMember.educationQualification ?? 'Unknown';

      // Group by education level, then by household number
      if (!groupedEducationLevels.containsKey(educationLevel)) {
        groupedEducationLevels[educationLevel] = {};
      }

      if (groupedEducationLevels[educationLevel]!
          .containsKey(familyMember.householdNumber)) {
        groupedEducationLevels[educationLevel]![familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedEducationLevels[educationLevel]![familyMember.householdNumber] =
            [familyMember];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  // New method to generate PDF
  Future<void> generatePdf() async {
    // Flatten all members from grouped education levels
    final List<FamilyMember> members = groupedEducationLevels.values
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
                    "Higher Educational Levels - Village Officer App",
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
                        "Total Households: ${groupedEducationLevels.values.fold(0, (total, householdMap) => total + householdMap.keys.length)}",
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
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(1),
                    },
                    children: groupedEducationLevels.entries
                        .map((levelEntry) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Text(
                                    "${levelEntry.key}",
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
                                    "${levelEntry.value.values.fold(0, (total, members) => total + members.length)}",
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
              itemCount: groupedEducationLevels.length,
              itemBuilder: (context, levelIndex) {
                final level = groupedEducationLevels.keys.toList()[levelIndex];
                final levelMap = groupedEducationLevels[level]!;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 15),
                    pw.Text(
                      "$level Qualifications",
                      style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 16,
                          color: PdfColors.green900),
                    ),
                    pw.SizedBox(height: 10),
                    pw.ListView.builder(
                      itemCount: levelMap.keys.length,
                      itemBuilder: (context, householdIndex) {
                        final householdNumber =
                            levelMap.keys.toList()[householdIndex];
                        final householdMembers = levelMap[householdNumber]!;

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
                                    0: pw.FlexColumnWidth(3),
                                    1: pw.FlexColumnWidth(2),
                                    2: pw.FlexColumnWidth(2),
                                    3: pw.FlexColumnWidth(2),
                                    4: pw.FlexColumnWidth(3),
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
          "Higher_Educational_Levels_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
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
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> orderedQualifications = [
      'Primary (1-5)',
      'Junior Secondary (6-9)',
      'Senior Secondary (10-11)',
      'O/L passed',
      'Collegiate Level (12-13)',
      'A/L passed',
      'Diploma',
      'Degree',
      'Higher Studies',
      'No Schooling'
    ];

    // Calculate the total number of families and members
    int totalFamilies = 0;
    int totalMembers = 0;

    groupedEducationLevels.forEach((educationLevel, households) {
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
            const Text('Higher Educational Levels of Adults'),
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
        itemCount: orderedQualifications.length,
        itemBuilder: (context, index) {
          String educationLevel = orderedQualifications[index];

          // Attempt to retrieve household members based on the education level
          Map<String, List<FamilyMember>>? householdMembers =
              groupedEducationLevels[educationLevel];

          // If no members are found for this education level, show a placeholder
          if (householdMembers == null || householdMembers.isEmpty) {
            return ListTile(
              title: Text(
                educationLevel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("No members found for this education level"),
            );
          }

          // Otherwise, display the members grouped by household as usual
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text('$educationLevel'),
              subtitle: Text('Households: ${householdMembers.keys.length}'),
              children: householdMembers.entries.map((entry) {
                String householdNumber = entry.key;
                List<FamilyMember> members = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExpansionTile(
                    title: Text(
                      '${householdMembers.keys.toList().indexOf(householdNumber) + 1}. Household Number: $householdNumber',
                    ),
                    subtitle: Text('Members: ${members.length}'),
                    children: members.asMap().entries.map((entry) {
                      int memberIndex = entry.key + 1;
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
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
