import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:village_officer_app/database_helper.dart'; // To import the Timer class

class ImportDatabaseScreen extends StatefulWidget {
  @override
  _ImportDatabaseScreenState createState() => _ImportDatabaseScreenState();
}

class _ImportDatabaseScreenState extends State<ImportDatabaseScreen> {
  String statusMessage = '';
  String statusType = '';
  String? selectedFilePath;
  List<String> importedFiles = [];
  bool isImporting = false;
  String currentDatabaseFile = '';
  bool isDatabaseImported = false;
  late List<Map<String, dynamic>> _dataList;

  @override
  void initState() {
    super.initState();
    _loadImportedFiles();
    _loadImportStatus();
  }

  Future<void> _loadImportedFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      importedFiles = prefs.getStringList('importedFiles') ?? [];
      currentDatabaseFile = prefs.getString('currentDatabaseFile')!;
    });
  }

  Future<void> _loadImportStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDatabaseImported = prefs.getBool('isDatabaseImported') ?? false;
    });
  }

  Future<void> _saveImportedFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('importedFiles', importedFiles);
    await prefs.setString('currentDatabaseFile', currentDatabaseFile);
    await prefs.setBool('isDatabaseImported', isDatabaseImported);
  }

  Future<void> _confirmDeleteFile(int index) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this file?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      await _deleteImportedFile(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteImportedFile(int index) async {
    setState(() {
      importedFiles.removeAt(index);
    });
    await _saveImportedFiles();
  }

  Future<void> selectDatabaseFile() async {
    try {
      await _checkAndRequestPermission();
      String? path = await FilePicker.platform
          .pickFiles(type: FileType.any)
          .then((result) => result?.files.single.path);

      setState(() {
        if (path != null) {
          selectedFilePath = path;
          _setStatusMessageWithDelay(
              'File selected: $selectedFilePath', 'default');
        } else {
          _setStatusMessageWithDelay('No file selected.', 'error');
        }
      });
    } catch (e) {
      _setStatusMessageWithDelay('Error selecting file: $e', 'error');
    }
  }

  Future<void> importDatabase() async {
    if (selectedFilePath == null) {
      _setStatusMessageWithDelay('Please select a file first.', 'error');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Import'),
          content:
              const Text('Are you sure you want to import this database file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isImporting = true;
      _setStatusMessageWithDelay('Starting import...', 'default');
    });

    try {
      final directory = await getDatabasesPath();
      String appDatabasePath = '$directory/village_officer.db';

      File selectedFile = File(selectedFilePath!);
      await selectedFile.copy(appDatabasePath);

      setState(() {
        importedFiles.add(selectedFilePath!);
        currentDatabaseFile = selectedFilePath!;
        isDatabaseImported = true;
        _setStatusMessageWithDelay(
            'Database imported successfully.', 'success');
        selectedFilePath = null;
      });

      await _saveImportedFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isImporting = false;
      });
    }
  }

  // Function to request storage permissions
  Future<void> _checkAndRequestPermission() async {
    // For Android 13 and above, MANAGE_EXTERNAL_STORAGE is required for broad access
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return;
      } else {
        PermissionStatus status =
            await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw 'Storage permission required.';
        }
      }
    }
  }

  void _setStatusMessageWithDelay(String message, String type) {
    setState(() {
      statusMessage = message;
      statusType = type;
    });

    // Skip clearing the message if it's about a selected file
    if (!message.startsWith('File selected:')) {
      Timer(const Duration(seconds: 3), () {
        setState(() {
          statusMessage = '';
          statusType = '';
        });
      });
    }
  }

  Color _getStatusBackgroundColor() {
    switch (statusType) {
      case 'success':
        return Colors.green[100]!;
      case 'error':
        return Colors.red[100]!;
      default:
        return Colors.blueGrey[100]!;
    }
  }

  IconData _getStatusIcon() {
    switch (statusType) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Future<void> _replaceCurrentDatabase(String filePath) async {
    if (filePath == currentDatabaseFile) {
      _setStatusMessageWithDelay(
          'This is already the current database.', 'error');
      return;
    }

    setState(() {
      isImporting = true;
      _setStatusMessageWithDelay('Replacing database...', 'default');
    });

    try {
      final directory = await getDatabasesPath();
      String appDatabasePath = '$directory/village_officer.db';

      File selectedFile = File(filePath);
      await selectedFile.copy(appDatabasePath);

      setState(() {
        currentDatabaseFile = filePath;
        isDatabaseImported = true;
      });

      await _saveImportedFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database replaced successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error replacing database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isImporting = false;
      });
    }
  }

  Future<void> switchDatabase(String newDatabasePath) async {
    try {
      // Replace the current database with the new database file
      await DatabaseHelper.instance.replaceDatabase(newDatabasePath);

      // Reload data from the active database
      await _loadDataFromActiveDatabase();

      if (kDebugMode) {
        print("Successfully switched to the new database at $newDatabasePath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error switching database: $e");
      }
      throw Exception("Failed to switch the database: $e");
    }
  }

  Future<void> _loadDataFromActiveDatabase() async {
    try {
      // Fetch all family members from the active database
      final data = await DatabaseHelper.instance.retrieveFamilyMembers();

      // Update the state with the fetched data
      setState(() {
        _dataList = data.cast<Map<String, dynamic>>();
      });

      if (kDebugMode) {
        print("Data successfully loaded from the active database.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading data from the active database: $e");
      }
      throw Exception("Failed to load data from the active database: $e");
    }
  }

  Widget _buildImportedFileList() {
    return ListView.builder(
      itemCount: importedFiles.length,
      itemBuilder: (context, index) {
        bool isCurrentDatabase = importedFiles[index] == currentDatabaseFile;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Added border radius
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              Icons.file_present, // Use an icon to represent files
              color: isCurrentDatabase ? Colors.green : Colors.blueGrey,
            ),
            title: Text(importedFiles[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isCurrentDatabase
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: isCurrentDatabase ? Colors.green : Colors.grey,
                  ),
                  onPressed: () =>
                      _replaceCurrentDatabase(importedFiles[index]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteFile(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Databases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Add help or info action here if needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: File Selection
            const SizedBox(height: 8),
            const Text(
              'Step 1: Select The Database File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: selectDatabaseFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                primary: Colors.green,
              ),
            ),
            const Divider(height: 32, color: Colors.grey),

            // Status Message Section
            if (statusMessage.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(), color: Colors.black54, size: 32),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Text(statusMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              statusMessage = '';
                              statusType = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32, color: Colors.grey),
                ],
              ),

            // Section: Import Database
            const Text(
              'Step 2: Import The Database File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isImporting ? null : importDatabase,
              icon: isImporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.import_export),
              label: const Text('Import'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                primary: Colors.green,
              ),
            ),
            const Divider(height: 32, color: Colors.grey),
            const SizedBox(height: 16),

            // Section: Imported Files
            const Text(
              'Step 3: Tick A Database File To Replace',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: importedFiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No files imported yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : _buildImportedFileList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
