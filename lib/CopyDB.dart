import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import 'DBPath.dart'; // Ensure this file exists and contains getDatabasePath()

Future<void> copyDatabase() async {
  if (kDebugMode) {
    print('Starting database copy process...');
  } // Log the start of the function

  String dbPath = await getDatabasePath();
  if (kDebugMode) {
    print('Current database path: $dbPath');
  } // Log the current database path

  String newPath =
      '/storage/emulated/0/Download/copy_of_database.db'; // Path where you want to save
  if (kDebugMode) {
    print('New database path for copy: $newPath');
  } // Log the new path for the copied database

  // Request storage permissions if not granted
  if (await Permission.storage.request().isGranted) {
    if (kDebugMode) {
      print('Storage permission granted. Proceeding with copy...');
    } // Log permission status
    try {
      File dbFile = File(dbPath);
      // Check if the database file exists before copying
      if (await dbFile.exists()) {
        if (kDebugMode) {
          print('Database file exists. Proceeding to copy...');
        } // Log existence of the file
        await dbFile.copy(newPath);
        if (kDebugMode) {
          print('Database copied successfully to $newPath');
        }
      } else {
        if (kDebugMode) {
          print(
              'Database file does not exist at $dbPath'); // Log if the file does not exist
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error copying database: $e'); // Log any error that occurs during copying
      }
    }
  } else {
    if (kDebugMode) {
      print(
          'Storage permission denied. Cannot copy database.'); // Log permission denial
    }
  }

  if (kDebugMode) {
    print('Database copy process completed.');
  } // Log the end of the function
}
