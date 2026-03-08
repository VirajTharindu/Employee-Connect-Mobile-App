import 'package:flutter_test/flutter_test.dart';
import 'package:employee_connect/data/datasources/local/database_helper.dart';
import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/data/services/family_report_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize ffi for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;

  group('DatabaseHelper CRUD Tests', () {
    setUp(() async {
      dbHelper = DatabaseHelper();
      // Use an in-memory database for testing
      await dbHelper.initDatabase(customPath: inMemoryDatabasePath);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Insert and Retrieve Family Member', () async {
      final member = FamilyMember(
        name: 'John Doe',
        nationalId: '123456789V',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        nationality: 'Sinhala',
        religion: 'Buddhism',
        householdNumber: 'H001',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        isSamurdiAid: true,
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(member);
      
      final members = await dbHelper.retrieveAllFamilyMembers();
      expect(members.length, 1);
      expect(members[0].name, 'John Doe');
      expect(members[0].isSamurdiAid, isTrue);
    });

    test('Filter by Household Number', () async {
      final m1 = FamilyMember(
        name: 'Member 1',
        nationalId: 'N1',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H001',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );
      final m2 = FamilyMember(
        name: 'Member 2',
        nationalId: 'N2',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H002',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(m1);
      await dbHelper.insertFamilyMember(m2);

      final h1Members = await dbHelper.retrieveFamilyMembersByHousehold('H001');
      expect(h1Members.length, 1);
      expect(h1Members[0].name, 'Member 1');
    });

    test('Delete Family Member by ID', () async {
      final member = FamilyMember(
        name: 'Delete Me',
        nationalId: 'D-999',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H-DEL',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(member);
      var members = await dbHelper.retrieveAllFamilyMembers();
      final id = members[0].id!;

      await dbHelper.deleteFamilyMemberById(id);
      members = await dbHelper.retrieveAllFamilyMembers();
      expect(members, isEmpty);
    });

    test('Update Family Member Data', () async {
      final member = FamilyMember(
        name: 'Old Name',
        nationalId: 'U-111',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H-UPD',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(member);
      var members = await dbHelper.retrieveAllFamilyMembers();
      final inserted = members[0];
      
      final updated = FamilyMember(
        id: inserted.id,
        name: 'New Name',
        nationalId: inserted.nationalId,
        birthday: inserted.birthday,
        age: 35,
        householdNumber: inserted.householdNumber,
        nationality: inserted.nationality,
        religion: inserted.religion,
        familyHeadType: inserted.familyHeadType,
        relationshipToHead: inserted.relationshipToHead,
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.updateFamilyMember(updated);
      
      final result = await dbHelper.retrieveAllFamilyMembers();
      expect(result[0].name, 'New Name');
      expect(result[0].age, 35);
    });

    test('Uniqueness Checks', () async {
       final member = FamilyMember(
        name: 'Unique User',
        nationalId: 'UNIQ-1',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H-UNIQ',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(member);
      
      expect(await dbHelper.isNationalIdUnique('UNIQ-1'), isFalse);
      expect(await dbHelper.isNationalIdUnique('UNIQ-NEW'), isTrue);
      
      expect(await dbHelper.isHouseholdNumberUnique('H-UNIQ'), isFalse);
      expect(await dbHelper.isHouseholdNumberUnique('H-NEW'), isTrue);
    });
  });

  group('DatabaseHelper Query Tests', () {
    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.initDatabase(customPath: inMemoryDatabasePath);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Query Aid Families', () async {
      final m1 = FamilyMember(
        name: 'Aswasuma Receiver',
        nationalId: 'A-1',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H1',
        isAswasumaAid: true,
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );
      final m2 = FamilyMember(
        name: 'Samurdhi Receiver',
        nationalId: 'S-1',
        birthday: DateTime(1990, 1, 1),
        age: 34,
        householdNumber: 'H2',
        isSamurdiAid: true,
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(m1);
      await dbHelper.insertFamilyMember(m2);

      final aswasuma = await dbHelper.queryAswasumaFamilies();
      expect(aswasuma.length, 1);
      expect(aswasuma[0]['name'], 'Aswasuma Receiver');

      final samurdhi = await dbHelper.querySamurdhiFamilies();
      expect(samurdhi.length, 1);
      expect(samurdhi[0]['name'], 'Samurdhi Receiver');
    });

    test('Query People Based on Age Groups', () async {
      final infant = FamilyMember(
        name: 'Infant',
        nationalId: 'I-1',
        birthday: DateTime.now().subtract(const Duration(days: 365)),
        age: 1,
        householdNumber: 'H1',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );
      final senior = FamilyMember(
        name: 'Senior',
        nationalId: 'S-70',
        birthday: DateTime(1950, 1, 1),
        age: 74,
        householdNumber: 'H2',
        nationality: 'Sinhala',
        religion: 'Buddhism',
        familyHeadType: 'Mother',
        relationshipToHead: 'Self',
        dateOfModified: DateTime.now().toIso8601String(),
      );

      await dbHelper.insertFamilyMember(infant);
      await dbHelper.insertFamilyMember(senior);

      final reportService = FamilyReportService(dbHelper);
      final groups = await reportService.getPeopleBasedOnAgeGroups();
      expect(groups['Infants and Toddlers (0-4 years)']!.length, 1);
      expect(groups['Seniors (65+ years)']!.length, 1);
    });
  });
}
