import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For preview and print
import 'database_helper.dart';
import 'family_member.dart';
import 'family_profile.dart';
import 'update_family_member_data.dart';
import 'package:file_saver/file_saver.dart';

class FamilyList extends StatefulWidget {
  @override
  _FamilyListState createState() => _FamilyListState();
}

class _FamilyListState extends State<FamilyList> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  Future<List<FamilyMember>>? familyMembersFuture;
  List<FamilyMember> familyMembers = [];
  int householdCount = 0;
  int memberCount = 0;
  Map<String, int> householdMemberCounts =
      {}; // New map to store members per household

  @override
  void initState() {
    super.initState();
    loadFamilyMembers();
  }

  // Method to load family members with detailed household counts
  void loadFamilyMembers() {
    familyMembersFuture = databaseHelper.retrieveFamilyMembers();
    familyMembersFuture!.then((members) {
      setState(() {
        Map<String, List<FamilyMember>> groupedByHousehold = {};
        for (var member in members) {
          if (!groupedByHousehold.containsKey(member.householdNumber)) {
            groupedByHousehold[member.householdNumber] = [];
          }
          groupedByHousehold[member.householdNumber]!.add(member);
        }

        householdCount = groupedByHousehold.keys.length;
        memberCount = members.length;

        // Calculate members per household
        householdMemberCounts.clear();
        groupedByHousehold.forEach((householdNumber, householdMembers) {
          householdMemberCounts[householdNumber] = householdMembers.length;
        });
      });
    });
  }

  Future<void> generatePdf() async {
    // Ensure data is loaded before generating the PDF
    final members = await familyMembersFuture ?? [];

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No family members found to generate PDF'),
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

    // Group members by household
    Map<String, List<FamilyMember>> groupedByHousehold = {};
    for (var member in members) {
      if (!groupedByHousehold.containsKey(member.householdNumber)) {
        groupedByHousehold[member.householdNumber] = [];
      }
      groupedByHousehold[member.householdNumber]!.add(member);
    }

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
                    "Family Registry Report - Village Officer App",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 17, color: PdfColors.green900),
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
                    "Total Households: ${groupedByHousehold.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                  pw.Text(
                    "Total Family Members: ${members.length}",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.green900),
                  ),
                ],
              ),
            ),

            // Detailed Household Information
            pw.ListView.builder(
              itemCount: groupedByHousehold.keys.length,
              itemBuilder: (context, index) {
                final householdNumber = groupedByHousehold.keys.toList()[index];
                final householdMembers = groupedByHousehold[householdNumber]!;

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
                            0: pw.FlexColumnWidth(1),
                            1: pw.FlexColumnWidth(2),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(1),
                            4: pw.FlexColumnWidth(2),
                            5: pw.FlexColumnWidth(2),
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
                                pw.Text("Relationship",
                                    style: pw.TextStyle(
                                        font: ttfBold,
                                        fontSize: 10,
                                        color: PdfColors.green900),
                                    textAlign: pw.TextAlign.center),
                                pw.Text("Date Modified",
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
                                        pw.Text(member.relationshipToHead,
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
    // Save the PDF and print it
    try {
      final tempDir = await getTemporaryDirectory();
      final currentDate = DateTime.now();
      final fileName =
          "Family_Registry_Report_Village_Officer_App_${currentDate.day}-${currentDate.month}-${currentDate.year}.pdf";
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

  // Navigation to FamilyProfile page
  void navigateToFamilyProfile(
      BuildContext context, List<FamilyMember> members) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyProfile(
          familyMembers: members,
        ),
      ),
    );
  }

  // Method to delete a household record and refresh the list
  void deleteHousehold(String householdNumber) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this household record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await databaseHelper.deleteFamilyByHousehold(householdNumber);

      setState(() {
        loadFamilyMembers(); // Reload members and update count
      });

      // Show a snackbar message after deletion is complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Household record deleted successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Navigation to UpdateFamilyMemberData page with selected household data
  void navigateToUpdatePage(BuildContext context, String householdNumber,
      List<FamilyMember> members) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateFamilyMemberData(
          householdNumber: householdNumber,
          familyMembers: members,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final updatedHouseholdNumber = result['householdNumber'];
        final updatedMembers = result['familyMembers'];

        // Remove old entries and add updated members to refresh the list
        familyMembers
            .removeWhere((member) => member.householdNumber == householdNumber);
        familyMembers.addAll(updatedMembers);

        loadFamilyMembers(); // Reload the future to trigger a re-render
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Family List'),
            Text(
              '$householdCount ${householdCount == 1 ? "Family" : "Families"} | $memberCount ${memberCount == 1 ? "Family Member" : "Family Members"}\n',
              style: const TextStyle(
                fontSize: 14, // Slightly smaller font to accommodate more text
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
        future: familyMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No family list found.'));
          } else {
            Map<String, List<FamilyMember>> groupedByHousehold = {};
            for (var member in snapshot.data!) {
              if (!groupedByHousehold.containsKey(member.householdNumber)) {
                groupedByHousehold[member.householdNumber] = [];
              }
              groupedByHousehold[member.householdNumber]!.add(member);
            }

            List<String> householdNumbers = groupedByHousehold.keys.toList();

            return ListView.builder(
              itemCount: householdNumbers.length,
              itemBuilder: (context, index) {
                final householdNumber = householdNumbers[index];
                final members = groupedByHousehold[householdNumber]!;

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Household Number: $householdNumber'),
                    subtitle: Text(
                      '${members.length} ${members.length == 1 ? 'Member' : 'Members'}: ${members.map((m) => m.name).join(", ")}',
                    ),
                    onTap: () {
                      navigateToFamilyProfile(context, members);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Update"),
                                content: const Text(
                                    "Are you sure you want to update this family details?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      navigateToUpdatePage(
                                          context, householdNumber, members);
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteHousehold(householdNumber),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
