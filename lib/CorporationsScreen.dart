import 'package:flutter/material.dart';
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

class CorporationsScreen extends StatefulWidget {
  @override
  _CorporationsScreenState createState() => _CorporationsScreenState();
}

class _CorporationsScreenState extends State<CorporationsScreen> {
  late Future<List<FamilyMember>> _corporationFamilies;
  Map<String, List<FamilyMember>> groupedCorporationFamilies =
      {}; // Initialize to avoid late initialization errors

  @override
  void initState() {
    super.initState();
    _corporationFamilies = _fetchCorporationFamilies();
  }

  Future<List<FamilyMember>> _fetchCorporationFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryCorporationEmployees();

    // Group the data
    Map<String, List<FamilyMember>> groupedFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedFamilies.containsKey(familyMember.householdNumber)) {
        groupedFamilies[familyMember.householdNumber]!.add(familyMember);
      } else {
        groupedFamilies[familyMember.householdNumber] = [familyMember];
      }
    }

    // After grouping the families, update the state to trigger a rebuild
    setState(() {
      groupedCorporationFamilies = groupedFamilies;
    });

    return familyMembers;
  }

  // New method to generate PDF
  Future<void> generatePdf() async {
    // Ensure data is loaded before generating the PDF
    final List<FamilyMember> members = groupedCorporationFamilies.values
        .expand((householdMembers) => householdMembers)
        .toList();

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Corporation Employees found to generate PDF'),
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
                    "Corporation Employees - Village Officer App",
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
                    "Total Households: ${groupedCorporationFamilies.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                  pw.Text(
                    "Total Corporation Employees: ${members.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                ],
              ),
            ),

            // Detailed Household Information
            pw.ListView.builder(
              itemCount: groupedCorporationFamilies.length,
              itemBuilder: (context, index) {
                final householdNumber =
                    groupedCorporationFamilies.keys.toList()[index];
                final householdMembers =
                    groupedCorporationFamilies[householdNumber]!;

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
          "Corporation_Employees_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
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
    // Ensure familyCount and memberCount are updated after the state is set
    int familyCount = groupedCorporationFamilies.keys.length;
    int memberCount = groupedCorporationFamilies.values
        .fold(0, (total, members) => total + members.length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Corporation Employees'),
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
      body: FutureBuilder<List<FamilyMember>>(
        future: _corporationFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No corporation employees found.'));
          }

          final householdNumbers = groupedCorporationFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers =
                  groupedCorporationFamilies[householdNumber]!;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ExpansionTile(
                  title:
                      Text('${index + 1}. Household Number: $householdNumber'),
                  subtitle: Text('Members: ${familyMembers.length}'),
                  children: familyMembers.asMap().entries.map((entry) {
                    int memberIndex = entry.key + 1;
                    FamilyMember familyMember = entry.value;

                    return ListTile(
                      title: Text(
                          '${getOrdinal(memberIndex)}: ${familyMember.name}'),
                      subtitle: Text('National ID: ${familyMember.nationalId}'),
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
