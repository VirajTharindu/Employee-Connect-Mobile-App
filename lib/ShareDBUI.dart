import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseScreen extends StatefulWidget {
  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  String statusMessage = '';
  bool isLoading = false;
  bool isExported = false; // Tracks export status
  String statusType = ''; // Tracks type of status ('success', 'error', 'info')

  final TextEditingController textController = TextEditingController();

  Future<String> getDatabasePath() async {
    try {
      final directory = await getDatabasesPath();
      return '$directory/village_officer.db';
    } catch (e) {
      updateStatus('Error getting database path: $e', 'error');
      return '';
    }
  }

  Future<void> copyDatabase() async {
    updateStatus('Starting database copy process...', 'info');
    setState(() => isLoading = true);

    await checkAndRequestPermission();

    String dbPath = await getDatabasePath();
    File dbFile = File(dbPath);

    if (await dbFile.exists()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        bool? shouldRename =
            await showRenameChoiceDialog(context, selectedDirectory);

        if (shouldRename == null || !shouldRename) {
          updateStatus('Database copy cancelled.', 'info');
        } else {
          String fileName = textController.text.trim();
          String fullPath = '$selectedDirectory/$fileName.db';
          await _copyToSelectedPath(dbFile, fullPath);
        }
      } else {
        updateStatus('No directory selected.', 'info');
      }
    } else {
      updateStatus('Database file does not exist at $dbPath', 'error');
    }

    setState(() => isLoading = false);
  }

  Future<void> _copyToSelectedPath(File dbFile, String newFilePath) async {
    try {
      await dbFile.copy(newFilePath);
      updateStatus('Database successfully copied to $newFilePath', 'success');
      setState(() => isExported = true);
    } catch (e) {
      updateStatus('Error copying database: $e', 'error');
      setState(() => isExported = false);
    }
  }

  Future<void> checkAndRequestPermission() async {
    if (await Permission.storage.isGranted) return;

    PermissionStatus status = await Permission.storage.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      updateStatus('Storage permission is required to proceed.', 'error');
    }
  }

  Future<bool?> showRenameChoiceDialog(
      BuildContext context, String directoryPath) async {
    String uniqueFilePath = await getUniqueFilePath(directoryPath);
    String suggestedFileName =
        uniqueFilePath.split('/').last.replaceAll('.db', '');

    textController.text = suggestedFileName;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Database?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Do you want to rename the database before exporting?'),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  hintText: 'Enter new file name',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getUniqueFilePath(String directoryPath) async {
    int counter = 2;
    String baseName = 'village_officer';
    String extension = '.db';
    String newPath = '$directoryPath/${baseName}_$counter$extension';

    while (await File(newPath).exists()) {
      counter++;
      newPath = '$directoryPath/${baseName}_$counter$extension';
    }

    return newPath;
  }

  void updateStatus(String message, String type) {
    setState(() {
      statusMessage = message;
      statusType = type;
    });

    // Clear the status message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        statusMessage = '';
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Align items in the center
          children: [
            const Text(
              'Step 1: Select The Database File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center, // Align button to the center
              child: SizedBox(
                width: double.infinity, // Ensure the button takes full width
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : copyDatabase,
                  icon: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        )
                      : const Icon(Icons.download),
                  label: isLoading
                      ? const Text('Exporting...')
                      : const Text('Copy Database File'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    primary: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center, // Align status message to the center
              child: SizedBox(
                width:
                    double.infinity, // Ensure status message takes full width
                child: StatusMessageWidget(
                    message: statusMessage, type: statusType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusMessageWidget extends StatelessWidget {
  final String message;
  final String type;

  const StatusMessageWidget({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case 'success':
        bgColor = Colors.green[100]!;
        icon = Icons.check_circle;
        break;
      case 'error':
        bgColor = Colors.red[100]!;
        icon = Icons.error;
        break;
      default:
        bgColor = Colors.blueGrey[100]!;
        icon = Icons.info;
        break;
    }

    return message.isEmpty
        ? Container()
        : Card(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              leading: Icon(icon, color: Colors.black54, size: 32),
              title: Text(
                message,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
  }
}
