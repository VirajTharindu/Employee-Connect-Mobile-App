import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'database_helper.dart';
import 'family_member.dart';

class TuberculosisAidScreen extends StatefulWidget {
  @override
  _TuberculosisAidScreenState createState() => _TuberculosisAidScreenState();
}

class _TuberculosisAidScreenState extends State<TuberculosisAidScreen> {
  Map<String, List<FamilyMember>> groupedTuberculosisFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchTuberculosisAidFamilies();
  }

  Future<void> _fetchTuberculosisAidFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryTuberculosisAidFamilies();

    final List<FamilyMember> familiesWithTuberculosisAid =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedTuberculosisFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithTuberculosisAid) {
      if (groupedTuberculosisFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedTuberculosisFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedTuberculosisFamilies[familyMember.householdNumber] = [
          familyMember
        ];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  // New method to generate PDF
  Future<void> generatePdf() async {
    // Ensure data is loaded before generating the PDF
    final List<FamilyMember> members = groupedTuberculosisFamilies.values
        .expand((householdMembers) => householdMembers)
        .toList();

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Tuberculosis Aid recipients found to generate PDF'),
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
                    "Tuberculosis Aid Recipients - Village Officer App",
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
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Total Households: ${groupedTuberculosisFamilies.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                  pw.Text(
                    "Total Tuberculosis Aid Recipients: ${members.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                ],
              ),
            ),

            // Detailed Household Information
            pw.ListView.builder(
              itemCount: groupedTuberculosisFamilies.length,
              itemBuilder: (context, index) {
                final householdNumber =
                    groupedTuberculosisFamilies.keys.toList()[index];
                final householdMembers =
                    groupedTuberculosisFamilies[householdNumber]!;

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.green200, width: 1),
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
                              "${index + 1}. ",
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
                            0: pw.FlexColumnWidth(2),
                            1: pw.FlexColumnWidth(3),
                            2: pw.FlexColumnWidth(3),
                            3: pw.FlexColumnWidth(2),
                          },
                          children: [
                            // Table Header
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.green50),
                              children: [
                                pw.Text("Family Head",
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
                                              householdMembers.indexOf(member) %
                                                          2 ==
                                                      0
                                                  ? PdfColors.white
                                                  : PdfColors.green50),
                                      children: [
                                        pw.Text(member.familyHeadType,
                                            style: pw.TextStyle(
                                                font: ttfRegular, fontSize: 9),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text(member.name,
                                            style: pw.TextStyle(
                                                font: ttfRegular, fontSize: 9),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("${member.nationalId}",
                                            style: pw.TextStyle(
                                                font: ttfRegular, fontSize: 9),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text("${member.age}",
                                            style: pw.TextStyle(
                                                font: ttfRegular, fontSize: 9),
                                            textAlign: pw.TextAlign.center),
                                        pw.Text(member.dateOfModified,
                                            style: pw.TextStyle(
                                                font: ttfRegular, fontSize: 9),
                                            textAlign: pw.TextAlign.center),
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
          ];
        },
      ),
    );

    // Save the PDF and print it
    try {
      final tempDir = await getTemporaryDirectory();
      final currentDate = DateTime.now();
      final fileName =
          "Tuberculosis_Aid_Recipients_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
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
    int familyCount = groupedTuberculosisFamilies.keys.length;
    int memberCount = groupedTuberculosisFamilies.values
        .fold(0, (total, members) => total + members.length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tuberculosis Aid receivers'),
            Text(
              '$familyCount ${familyCount == 1 ? "Family" : "Families"} | $memberCount ${memberCount == 1 ? "Family Member" : "Family Members"}',
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
      body: groupedTuberculosisFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Tuberculosis Aid recipients.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: groupedTuberculosisFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedTuberculosisFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedTuberculosisFamilies[householdNumber]!;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  child: ExpansionTile(
                    title: Text(
                        '${index + 1}. Household Number: $householdNumber'),
                    subtitle: Text('Members: ${members.length}'),
                    children: members.asMap().entries.map((entry) {
                      int memberIndex = entry.key + 1;
                      FamilyMember familyMember = entry.value;

                      return ListTile(
                        title: Text(
                            '${getOrdinal(memberIndex)}: ${familyMember.name}'),
                        subtitle:
                            Text('National ID: ${familyMember.nationalId}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
