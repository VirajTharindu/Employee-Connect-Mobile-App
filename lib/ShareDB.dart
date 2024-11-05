import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

Future<void> importDatabase() async {
  try {
    // Allow the user to select the database file to import
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'], // Limit to .db files
    );

    if (result != null) {
      // Get the selected file path
      String selectedFilePath = result.files.single.path!;
      File selectedFile = File(selectedFilePath);

      // Define the path where the app's database is stored
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(appDocDir.path, 'village_officer.db');

      // Copy the selected database file to the app's database path
      await selectedFile.copy(dbPath);

      if (kDebugMode) {
        print("Database imported successfully to $dbPath");
      }
    } else {
      if (kDebugMode) {
        print("No file selected");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error importing database: $e");
    }
  }
}

Future<void> exportDatabase() async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, 'village_officer.db');

    File dbFile = File(dbPath);

    if (await dbFile.exists()) {
      // Choose a location to save the exported file
      String exportPath = '/path/to/export/location/village_officer.db';
      await dbFile.copy(exportPath);

      if (kDebugMode) {
        print("Database exported to $exportPath");
      }
    } else {
      if (kDebugMode) {
        print("Database file does not exist");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error exporting database: $e");
    }
  }
}
