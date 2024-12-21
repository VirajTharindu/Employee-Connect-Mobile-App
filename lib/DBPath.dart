import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

Future<String> getDatabasePath() async {
  try {
    // Log the start of the function
    if (kDebugMode) {
      print('Getting database path...');
    }

    // Get the databases directory
    final directory = await getDatabasesPath();
    if (kDebugMode) {
      print('Databases directory: $directory');
    }

    // Construct the full path to the database file
    String dbPath =
        '$directory/village_officer.db'; // Replace with your actual database name
    if (kDebugMode) {
      print('Full database path: $dbPath');
    }

    return dbPath;
  } catch (e) {
    // Log any errors that occur
    if (kDebugMode) {
      print('Error getting database path: $e');
    }
    return ''; // Return an empty string or handle as needed
  }
}
