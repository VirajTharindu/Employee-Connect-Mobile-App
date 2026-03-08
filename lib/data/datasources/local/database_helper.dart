// database_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/data/models/family_member_model.dart';
import 'package:employee_connect/data/datasources/local/database_constants.dart';
import 'package:employee_connect/domain/repositories/family_repository.dart';

class DatabaseHelper implements FamilyRepository {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  String? _currentDatabasePath;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  String? get currentDatabasePath => _currentDatabasePath;

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _currentDatabasePath = null;
    }
  }

  Future<void> initDatabase({String? customPath}) async {
    if (_database != null) {
      await close();
    }

    final directory = await getDatabasesPath();
    String path = customPath ?? join(directory, 'employee_connect.db');
    _currentDatabasePath = path;

    if (kDebugMode) {
      print("Initializing database at path: $path");
    }

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(DatabaseConstants.createTableFamilyMembers);
      },
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDatabase();
    return _database!;
  }

  Future<void> replaceDatabase(String newDatabaseFilePath) async {
    try {
      if (!await File(newDatabaseFilePath).exists()) {
        throw Exception('New database file does not exist');
      }
      await close();
      final directory = await getDatabasesPath();
      final defaultDbPath = join(directory, 'employee_connect.db');
      final existingDb = File(defaultDbPath);
      if (await existingDb.exists()) {
        final backupPath = '${defaultDbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
        await existingDb.copy(backupPath);
      }
      await File(newDatabaseFilePath).copy(defaultDbPath);
      await initDatabase();
      final db = await database;
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      if (!tables.any((table) => table['name'] == DatabaseConstants.tableFamilyMembers)) {
        throw Exception('Invalid database structure');
      }
    } catch (e) {
      await initDatabase();
      throw Exception("Failed to replace database: $e");
    }
  }

  // Core Data Operations using Model
  Future<void> insertFamilyMember(FamilyMember member) async {
    final db = await database;
    final model = FamilyMemberModel.fromEntity(member);
    await db.insert(
      DatabaseConstants.tableFamilyMembers,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<FamilyMember>> retrieveAllFamilyMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers);
    return List.generate(maps.length, (i) {
      return FamilyMemberModel.fromMap(maps[i]);
    });
  }

  Future<List<FamilyMember>> retrieveFamilyMembersByHousehold(String householdNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableFamilyMembers,
      where: '${DatabaseConstants.colHouseholdNumber} = ?',
      whereArgs: [householdNumber],
    );
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<void> deleteFamilyByHousehold(String householdNumber) async {
    final db = await database;
    await db.delete(
      DatabaseConstants.tableFamilyMembers,
      where: '${DatabaseConstants.colHouseholdNumber} = ?',
      whereArgs: [householdNumber],
    );
  }

  Future<void> deleteFamilyMemberById(int id) async {
    final db = await database;
    await db.delete(
      DatabaseConstants.tableFamilyMembers,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFamilyData(String householdNumber, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update(
      DatabaseConstants.tableFamilyMembers,
      updatedData,
      where: '${DatabaseConstants.colHouseholdNumber} = ?',
      whereArgs: [householdNumber],
    );
  }

  Future<int> updateFamilyMember(FamilyMember member) async {
    final db = await database;
    final model = FamilyMemberModel.fromEntity(member);
    return await db.update(
      DatabaseConstants.tableFamilyMembers,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> updateDateOfModified(FamilyMember member) async {
    final db = await database;
    Map<String, dynamic> updatedData = {
      DatabaseConstants.colDateOfModified: DateTime.now().toIso8601String(),
    };
    return await db.update(
      DatabaseConstants.tableFamilyMembers,
      updatedData,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> updateFamilyDateOfModified(String householdNumber) async {
    final db = await database;
    Map<String, dynamic> updatedData = {
      DatabaseConstants.colDateOfModified: DateTime.now().toIso8601String(),
    };
    await db.update(
      DatabaseConstants.tableFamilyMembers,
      updatedData,
      where: '${DatabaseConstants.colHouseholdNumber} = ?',
      whereArgs: [householdNumber],
    );
  }

  Future<Map<String, dynamic>> getFamilyMemberData(String householdNumber) async {
    final db = await database;
    final result = await db.query(
      DatabaseConstants.tableFamilyMembers,
      where: '${DatabaseConstants.colHouseholdNumber} = ?',
      whereArgs: [householdNumber],
    );
    return result.isEmpty ? {} : result.first;
  }

  // Aid Queries
  Future<List<Map<String, dynamic>>> querySamurdhiFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsSamurdhiAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryAswasumaFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsAswasumaAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryWedihitiFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsWedihitiAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryMahajanadaraFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsMahajanadaraAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryAbhadithaFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsAbhadithaAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryShishshyadaraFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsShishshyadaraAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryPilikadaraFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsPilikadaraAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryTuberculosisAidFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsTuberculosisAid} = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> queryAnyAidFamilies() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colIsAnyAid} = ?', whereArgs: [1]);
  }

  // Statistics Queries
  Future<List<Map<String, dynamic>>> queryAllStudentFamilyMembers({
    required int minAge,
    required int maxAge,
    required String dateOfModifiedPattern,
  }) async {
    final db = await database;
    final List<String> validGrades = List.generate(13, (index) => (index + 1).toString());
    final String validGradesString = validGrades.map((grade) => "'$grade'").join(', ');
    return await db.rawQuery('''
      SELECT * FROM ${DatabaseConstants.tableFamilyMembers}
      WHERE ${DatabaseConstants.colGrade} IN ($validGradesString)
        AND ${DatabaseConstants.colAge} BETWEEN ? AND ?
        AND ${DatabaseConstants.colDateOfModified} LIKE ?
      ''', [minAge, maxAge, dateOfModifiedPattern]);
  }

  Future<List<Map<String, dynamic>>> queryReligionFamilyMembers() async {
    final db = await database;
    final List<String> religions = ['Buddhism', 'Hinduism', 'Islam', 'Christianity', 'Other'];
    final String religionsString = religions.map((r) => "'$r'").join(', ');
    return await db.rawQuery('SELECT * FROM ${DatabaseConstants.tableFamilyMembers} WHERE ${DatabaseConstants.colReligion} IN ($religionsString)');
  }

  Future<List<Map<String, dynamic>>> queryNationalityFamilyMembers() async {
    final db = await database;
    final List<String> nationalities = ['Sinhala', 'Tamil', 'Muslim', 'Malay', 'Burgher', 'Other'];
    final String nationalitiesString = nationalities.map((n) => "'$n'").join(', ');
    return await db.rawQuery('SELECT * FROM ${DatabaseConstants.tableFamilyMembers} WHERE ${DatabaseConstants.colNationality} IN ($nationalitiesString)');
  }

  Future<List<Map<String, dynamic>>> queryHigherEducationFamilyMembers() async {
    final db = await database;
    final List<String> q = ['Primary (1-5)', 'Junior Secondary (6-9)', 'Senior Secondary (10-11)', 'O/L passed', 'Collegiate Level (12-13)', 'A/L passed', 'Diploma', 'Degree', 'Higher Studies', 'No Schooling'];
    final String qString = q.map((i) => "'$i'").join(', ');
    return await db.rawQuery('SELECT * FROM ${DatabaseConstants.tableFamilyMembers} WHERE ${DatabaseConstants.colEducationQualification} IN ($qString)');
  }

  // Job Queries
  Future<List<FamilyMember>> queryGovernmentEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Government']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> queryPrivateEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Private']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> querySemiGovernmentEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Semi-Government']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> queryCorporationEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Corporations']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> queryForcesEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Forces']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> queryPoliceEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Police']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> querySelfEmployedEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['Self-Employed (Business)']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<List<FamilyMember>> queryNoJobEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colJobType} = ?', whereArgs: ['No Job']);
    return List.generate(maps.length, (i) => FamilyMemberModel.fromMap(maps[i]));
  }

  Future<bool> isHouseholdNumberUnique(String householdNumber) async {
    final db = await database;
    final result = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colHouseholdNumber} = ?', whereArgs: [householdNumber]);
    return result.isEmpty;
  }

  Future<bool> isNationalIdUnique(String? nationalId) async {
    final db = await database;
    final result = await db.query(DatabaseConstants.tableFamilyMembers, where: '${DatabaseConstants.colNationalId} = ?', whereArgs: [nationalId]);
    return result.isEmpty;
  }
}
