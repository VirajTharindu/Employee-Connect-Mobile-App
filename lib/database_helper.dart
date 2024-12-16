import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'family_member.dart'; // Import the FamilyMember model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  String? _currentDatabasePath;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  // Add getter for current database path
  String? get currentDatabasePath => _currentDatabasePath;

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _currentDatabasePath = null; // Reset the current database path
    }
  }

  Future<void> initDatabase({String? customPath}) async {
    if (_database != null) {
      await close();
    }

    final directory = await getDatabasesPath();
    String path = customPath ?? join(directory, 'village_officer.db');
    _currentDatabasePath = path; // Store the current database path

    if (kDebugMode) {
      print("Initializing database at path: $path");
    }

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE family_members(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            nationalId TEXT UNIQUE,
            birthday TEXT,
            age INTEGER,
            nationality TEXT,
            religion TEXT,
            educationQualification TEXT,
            jobType TEXT,
            isSamurdiAid INTEGER,
            isAswasumaAid INTEGER,
            isWedihitiAid INTEGER,
            isMahajanadaraAid INTEGER,
            isAbhadithaAid INTEGER,
            isShishshyadaraAid INTEGER,
            isPilikadaraAid INTEGER,
            isTuberculosisAid INTEGER,
            isAnyAid INTEGER,
            householdNumber TEXT,
            familyHeadType TEXT,
            relationshipToHead TEXT,
            grade TEXT,
            dateOfModified TEXT DEFAULT (datetime('now', 'localtime'))
          )
        ''');
      },
      onOpen: (db) {
        if (kDebugMode) {
          print("Database opened successfully at: $path");
        }
      },
    );
  }

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDatabase();
    return _database!;
  }

  // Replace the current database with a new one
  Future<void> replaceDatabase(String newDatabaseFilePath) async {
    try {
      // Validate the new database file
      if (!await File(newDatabaseFilePath).exists()) {
        throw Exception('New database file does not exist');
      }

      // Close existing database connection
      await close();

      final directory = await getDatabasesPath();
      final defaultDbPath = join(directory, 'village_officer.db');

      // Create a backup of the current database if it exists
      final existingDb = File(defaultDbPath);
      if (await existingDb.exists()) {
        final backupPath =
            '${defaultDbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
        await existingDb.copy(backupPath);
      }

      // Copy new database to app's database directory
      await File(newDatabaseFilePath).copy(defaultDbPath);

      // Initialize the new database with proper cleanup
      await close();
      await initDatabase();

      // Verify the new database
      final db = await database;
      final tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

      if (!tables.any((table) => table['name'] == 'family_members')) {
        throw Exception('Invalid database structure');
      }

      if (kDebugMode) {
        print("Database replaced successfully with: $newDatabaseFilePath");
        print("New database opened at: $defaultDbPath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error replacing database: $e");
      }
      // Attempt to recover from failed replacement
      await close();
      await initDatabase();
      throw Exception("Failed to replace database: $e");
    }
  }

  // Insert a FamilyMember record into the database
  Future<void> insertFamilyMember(FamilyMember member) async {
    final db = await database;
    await db.insert(
      'family_members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (kDebugMode) {
      print("Inserted family member: ${member.toMap()}");
    } // Debugging line
  }

  // Retrieve all FamilyMember records from the database
  Future<List<FamilyMember>> retrieveFamilyMembers() async {
    final db = await database;

    // Force close and reopen the database to ensure fresh data
    //await close();
    //await initDatabase(customPath: _currentDatabasePath);

    final List<Map<String, dynamic>> maps = await db.query('family_members');

    if (kDebugMode) {
      print(
          "Retrieved ${maps.length} family members from database at: $_currentDatabasePath");
    }

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Retrieve FamilyMember records by household number
  Future<List<FamilyMember>> retrieveFamilyMembersByHousehold(
      String householdNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'family_members', // Change this to your actual table name
      where: 'householdNumber = ?',
      whereArgs: [householdNumber],
    );

    return List.generate(maps.length, (index) {
      return FamilyMember.fromMap(maps[index]);
    });
  }

  Future<void> deleteFamilyByHousehold(String householdNumber) async {
    final db = await database;
    await db.delete(
      'family_members', // Use the name of your table here
      where: 'householdNumber = ?',
      whereArgs: [householdNumber],
    );
  }

  Future<void> deleteFamilyMemberById(int Id) async {
    final db = await database;
    await db.delete(
      'family_members',
      where: 'Id = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updateFamilyData(
      String householdNumber, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update(
      'family_members', // Replace with your actual table name
      updatedData,
      where: 'householdNumber = ?',
      whereArgs: [householdNumber],
    );
  }

  // Method to update an existing family member
  Future<int> updateFamilyMember(FamilyMember member) async {
    final db = await database;

    // Map the `FamilyMember` object to a database-compatible format
    Map<String, dynamic> memberData = {
      'name': member.name,
      'nationalId': member.nationalId,
      'birthday': member.birthday.toIso8601String(),
      'age': member.age,
      'nationality': member.nationality,
      'religion': member.religion,
      'educationQualification': member.educationQualification,
      'jobType': member.jobType,
      'familyHeadType': member.familyHeadType,
      'relationshipToHead': member.relationshipToHead,
      'householdNumber': member.householdNumber,
      'grade': member.grade,
      'dateOfModified': DateTime.now().toIso8601String(),
      'isSamurdiAid': member.isSamurdiAid ? 1 : 0,
      'isAswasumaAid': member.isAswasumaAid ? 1 : 0,
      'isWedihitiAid': member.isWedihitiAid ? 1 : 0,
      'isMahajanadaraAid': member.isMahajanadaraAid ? 1 : 0,
      'isAbhadithaAid': member.isAbhadithaAid ? 1 : 0,
      'isShishshyadaraAid': member.isShishshyadaraAid ? 1 : 0,
      'isPilikadaraAid': member.isPilikadaraAid ? 1 : 0,
      'isAnyAid': member.isAnyAid ? 1 : 0,
      'isTuberculosisAid': member.isTuberculosisAid ? 1 : 0,
      // Add other fields if necessary
    };

    // Update query: Assuming the primary key is 'id' or a combination of 'householdNumber' and 'nationalId'
    return await db.update(
      'family_members', // Replace with your actual table name
      memberData,
      where: 'id = ?',
      whereArgs: [member.id], // Use id as the primary key
    );
  }

// Method to update only the 'dateOfModified' field of an existing family member
  Future<int> updateDateOfModified(FamilyMember member) async {
    final db = await database;

    // Map to update only the 'dateOfModified' field
    Map<String, dynamic> updatedData = {
      'dateOfModified':
          DateTime.now().toIso8601String(), // Set current timestamp
    };

    // Update query: Assuming the primary key is 'id' or a combination of 'householdNumber' and 'nationalId'
    return await db.update(
      'family_members', // Replace with your actual table name
      updatedData,
      where: 'id = ?', // Use the primary key for updating the record
      whereArgs: [member.id], // Use id as the primary key
    );
  }

// Function to update 'dateOfModified' for the family
  Future<void> updateFamilyDateOfModified(String householdNumber) async {
    final db = await database;

    // Map to update only the 'dateOfModified' field for the family
    Map<String, dynamic> updatedData = {
      'dateOfModified':
          DateTime.now().toIso8601String(), // Set current timestamp
    };

    // Update query to modify the family's 'dateOfModified' based on the household number
    await db.update(
      'family_members', // Replace with your actual family table name
      updatedData,
      where: 'householdNumber = ?',
      whereArgs: [householdNumber], // Use householdNumber to update the family
    );
  }

// Fetch family data (assuming you have a method like this)
  Future<Map<String, dynamic>> getFamilyMemberData(
      String householdNumber) async {
    try {
      final db = await database;
      final result = await db.query(
        'family_members',
        where: 'householdNumber = ?',
        whereArgs: [householdNumber],
      );

      if (result.isEmpty) {
        if (kDebugMode) {
          print('No family data found for household number: $householdNumber');
        }
        return {}; // Return an empty map or handle it as needed
      }

      return result.first;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      throw Exception('Failed to fetch family data');
    }
  }

  // Method to query families receiving Samurdhi aid
  Future<List<Map<String, dynamic>>> querySamurdhiFamilies() async {
    final db = await database; // Get a reference to the database

    // Query the family_data table where isSamurdiAid is true (1)
    return await db
        .query('family_members', where: 'isSamurdiAid = ?', whereArgs: [1]);
  }

  // Method to query families receiving Aswasuma aid
  Future<List<Map<String, dynamic>>> queryAswasumaFamilies() async {
    final db = await database;
    return await db.query(
      'family_members',
      where: 'isAswasumaAid = ?',
      whereArgs: [1], // Assuming 1 means receiving Aswasuma aid
    );
  }

  /// Method to query families receiving Wedihiti aid
  Future<List<Map<String, dynamic>>> queryWedihitiFamilies() async {
    final db = await database;

    // Query the family_members table where isWedihitiAid is 1
    return await db.query(
      'family_members',
      where: 'isWedihitiAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Wedihiti aid
    );
  }

  /// Method to query families receiving Mahajanadara aid
  Future<List<Map<String, dynamic>>> queryMahajanadaraFamilies() async {
    final db = await database;

    // Query the family_members table where isMahajanadaraAid is 1
    return await db.query(
      'family_members',
      where: 'isMahajanadaraAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Mahajanadara aid
    );
  }

  /// Method to query families receiving Abhaditha aid
  Future<List<Map<String, dynamic>>> queryAbhadithaFamilies() async {
    final db = await database;

    // Query the family_members table where isAbhadithaAid is 1
    return await db.query(
      'family_members',
      where: 'isAbhadithaAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Abhaditha aid
    );
  }

  /// Method to query families receiving Shishshyadara aid
  Future<List<Map<String, dynamic>>> queryShishshyadaraFamilies() async {
    final db = await database;

    // Query the family_members table where isShishshyadaraAid is 1

    return await db.query(
      'family_members',
      where: 'isShishshyadaraAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Shishshyadara aid
    );
  }

  /// Method to query families receiving Pilikadara aid
  Future<List<Map<String, dynamic>>> queryPilikadaraFamilies() async {
    final db = await database;

    // Query the family_members table where isPilikadaraAid is 1
    return await db.query(
      'family_members',
      where: 'isPilikadaraAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Pilikadara aid
    );
  }

  Future<List<Map<String, dynamic>>> queryTuberculosisAidFamilies() async {
    final db = await database;

    // Query the family_members table where isTuberculosisAid is 1
    return await db.query(
      'family_members',
      where: 'isTuberculosisAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving Tuberculosis aid
    );
  }

  /// Method to query families receiving any kind of aid
  Future<List<Map<String, dynamic>>> queryAnyAidFamilies() async {
    final db = await database;

    // Query the family_members table where isAnyAid is 1
    return await db.query(
      'family_members',
      where: 'isAnyAid = ?',
      whereArgs: [1], // Assuming 1 indicates receiving any kind of aid
    );
  }

  Future<List<Map<String, dynamic>>> queryAllStudentFamilyMembers({
    required int minAge,
    required int maxAge,
    required String dateOfModifiedPattern,
  }) async {
    final db = await database; // Get the database instance

    // Define the grades you want to filter by
    final List<String> validGrades =
        List.generate(13, (index) => (index + 1).toString());

    // Convert the list of valid grades into a comma-separated string for the SQL query
    final String validGradesString =
        validGrades.map((grade) => "'$grade'").join(', ');

    // Query the database for family members with grades between 1 and 13,
    // age within the specified range, and date matching the specified pattern
    return await db.rawQuery(
      '''
    SELECT * FROM family_members
    WHERE grade IN ($validGradesString)
      AND age BETWEEN ? AND ?
      AND dateOfModified LIKE ?
    ''',
      [minAge, maxAge, dateOfModifiedPattern],
    );
  }

  Future<List<Map<String, dynamic>>> queryReligionFamilyMembers() async {
    final db = await database; // Get the database instance

    // Define the list of religions you want to filter by
    final List<String> religions = [
      'Buddhism',
      'Hinduism',
      'Islam',
      'Christianity',
      'Other'
    ];

    // Convert the list into a comma-separated string with single quotes for the SQL query
    final String religionsString =
        religions.map((religion) => "'$religion'").join(', ');

    // Query the database for family members whose religion matches any of the specified options
    return await db.rawQuery(
        'SELECT * FROM family_members WHERE religion IN ($religionsString)');
  }

  Future<List<Map<String, dynamic>>> queryNationalityFamilyMembers() async {
    final db = await database; // Get the database instance

    // Define the list of nationalities you want to filter by
    final List<String> nationalities = [
      'Sinhala',
      'Tamil',
      'Muslim',
      'Malay',
      'Burgher',
      'Other'
    ];

    // Convert the list into a comma-separated string with single quotes for the SQL query
    final String nationalitiesString =
        nationalities.map((nationality) => "'$nationality'").join(', ');

    // Query the database for family members whose nationality matches any of the specified options
    return await db.rawQuery(
        'SELECT * FROM family_members WHERE nationality IN ($nationalitiesString)');
  }

  Future<List<Map<String, dynamic>>> queryHigherEducationFamilyMembers() async {
    final db = await database; // Get the database instance

    // Define the list of education qualifications you want to filter by
    final List<String> educationQualifications = [
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

    // Convert the list into a comma-separated string with single quotes for the SQL query
    final String qualificationsString = educationQualifications
        .map((qualification) => "'$qualification'")
        .join(', ');

    // Query the database for family members whose education qualification matches any of the specified levels
    return await db.rawQuery(
        'SELECT * FROM family_members WHERE educationQualification IN ($qualificationsString)');
  }

  Future<Map<String, List<FamilyMember>>> getPeopleBasedOnAgeGroups() async {
    final db = await database;

    // Query all family members
    final List<Map<String, dynamic>> maps = await db.query('family_members');

    // Convert query results into FamilyMember objects
    final List<FamilyMember> members =
        maps.map((map) => FamilyMember.fromMap(map)).toList();

    // Define age groups
    Map<String, List<FamilyMember>> ageGroups = {
      'Infants and Toddlers (0-4 years)': [],
      'Children (5-14 years)': [],
      'Youth (15-24 years)': [],
      'Adults (25-54 years)': [],
      'Older Adults (55-64 years)': [],
      'Seniors (65+ years)': [],
    };

    // Sort family members into age groups
    for (var member in members) {
      if (member.age >= 0 && member.age <= 4) {
        ageGroups['Infants and Toddlers (0-4 years)']!.add(member);
      } else if (member.age >= 5 && member.age <= 14) {
        ageGroups['Children (5-14 years)']!.add(member);
      } else if (member.age >= 15 && member.age <= 24) {
        ageGroups['Youth (15-24 years)']!.add(member);
      } else if (member.age >= 25 && member.age <= 54) {
        ageGroups['Adults (25-54 years)']!.add(member);
      } else if (member.age >= 55 && member.age <= 64) {
        ageGroups['Older Adults (55-64 years)']!.add(member);
      } else if (member.age >= 65) {
        ageGroups['Seniors (65+ years)']!.add(member);
      }
    }

    return ageGroups;
  }

  Future<Map<String, List<FamilyMember>>>
      getPeopleBasedOnAgeGroupsLegally() async {
    final db = await database;

    // Query all family members
    final List<Map<String, dynamic>> maps = await db.query('family_members');

    // Convert query results into FamilyMember objects
    final List<FamilyMember> members =
        maps.map((map) => FamilyMember.fromMap(map)).toList();

    // Define age groups
    Map<String, List<FamilyMember>> ageGroups = {
      'Children (<18 years)': [],
      'Adults (18+ years)': [],
    };

    // Sort family members into the two age groups
    for (var member in members) {
      if (member.age < 18) {
        ageGroups['Children (<18 years)']!.add(member);
      } else {
        ageGroups['Adults (18+ years)']!.add(member);
      }
    }

    return ageGroups;
  }

  // Method to query family members with the jobType as 'Government'
  Future<List<FamilyMember>> queryGovernmentEmployees() async {
    final db = await database;

    // Query the family_members table where jobType is 'Government'
    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Government'],
    );

    // Convert the query result into a list of FamilyMember objects
    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Private'
  Future<List<FamilyMember>> queryPrivateEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Private'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Semi-Government'
  Future<List<FamilyMember>> querySemiGovernmentEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Semi-Government'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Corporations'
  Future<List<FamilyMember>> queryCorporationEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Corporations'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Forces'
  Future<List<FamilyMember>> queryForcesEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Forces'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Police'
  Future<List<FamilyMember>> queryPoliceEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Police'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'Self-Employed (Business)'
  Future<List<FamilyMember>> querySelfEmployedEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['Self-Employed (Business)'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Method to query family members with the jobType as 'No Job'
  Future<List<FamilyMember>> queryNoJobEmployees() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'jobType = ?',
      whereArgs: ['No Job'],
    );

    return List.generate(maps.length, (i) {
      return FamilyMember.fromMap(maps[i]);
    });
  }

  // Check if household number is unique
  Future<bool> isHouseholdNumberUnique(String householdNumber) async {
    final db = await database;
    final result = await db.query(
      'family_members',
      where: 'householdNumber = ?',
      whereArgs: [householdNumber],
    );
    return result.isEmpty;
  }

  // Check if national ID is unique
  Future<bool> isNationalIdUnique(String? nationalId) async {
    final db = await database;
    final result = await db.query(
      'family_members',
      where: 'nationalId = ?',
      whereArgs: [nationalId],
    );
    return result.isEmpty;
  }
}
