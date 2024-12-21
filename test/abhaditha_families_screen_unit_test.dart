import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_ffi
import 'package:village_officer_app/Abhadhitha.dart';
import 'package:village_officer_app/database_helper.dart';
import 'package:village_officer_app/family_member.dart';

import 'database_helper_test.mocks.dart';

void main() {
  setUpAll(() {
    // Initialize databaseFactory for sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('getOrdinal Method', () {
    test('returns correct ordinal suffix', () {
      final screen = AbhadithaFamiliesScreenState();

      expect(screen.getOrdinal(1), '1st');
      expect(screen.getOrdinal(2), '2nd');
      expect(screen.getOrdinal(3), '3rd');
      expect(screen.getOrdinal(4), '4th');
      expect(screen.getOrdinal(11), '11th');
      expect(screen.getOrdinal(12), '12th');
      expect(screen.getOrdinal(13), '13th');
      expect(screen.getOrdinal(21), '21st');
      expect(screen.getOrdinal(22), '22nd');
      expect(screen.getOrdinal(23), '23rd');
      expect(screen.getOrdinal(24), '24th');
    });
  });

  group('_fetchAbhadithaFamilies Method', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late AbhadithaFamiliesScreenState screenState;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      screenState = AbhadithaFamiliesScreenState();
    });

    test('fetchAbhadithaFamilies fetches and groups family members correctly',
        () async {
      // Arrange
      final familyMembersMap = [
        {
          'householdNumber': '001',
          'name': 'Alice',
          'age': 30,
          'familyHeadType': 'Family Head - Male'
        },
        {
          'householdNumber': '002',
          'name': 'Bob',
          'age': 25,
          'familyHeadType': 'Family Head - Male'
        },
        {
          'householdNumber': '003',
          'name': 'Charlie',
          'age': 40,
          'familyHeadType': 'Family Head - Male'
        },
        {
          'householdNumber': null, // Missing householdNumber
          'name': 'Alice',
          'age': 30,
          'familyHeadType': 'Family Head - Male'
        },
        {
          'householdNumber': '002',
          'name': null, // Missing name
          'age': 25,
          'familyHeadType': 'Family Head - Male'
        },

        {
          'householdNumber': '001',
          'name': 'Bob',
          'age': 28,
          'familyHeadType': 'Family Head - Female'
        },

        {
          'householdNumber': '001',
          'name': 'Alice',
          'age': 'not_a_number', // Invalid data type for age
          'familyHeadType': 'Family Head - Male'
        },

        {
          'householdNumber': '001',
          'name': 'Alice',
          'age': 30,
          'familyHeadType': 'Family Head - Male'
        },
        {
          'householdNumber': '001', // Duplicate entry for same household
          'name': 'Alice',
          'age': 30,
          'familyHeadType': 'Family Head - Male'
        },

        {
          'householdNumber': '001',
          'name': 'Alice',
          'age': 30,
        }, // Missing 'familyHeadType'
      ];

      when(mockDatabaseHelper.queryAbhadithaFamilies())
          .thenAnswer((_) async => familyMembersMap);

      // Act
      final groupedFamilies = screenState.groupFamilyMembers(
          familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList());

      // Assert
      expect(groupedFamilies.length, 2);
      expect(groupedFamilies['001']!.length, 2);
      expect(groupedFamilies['002']!.length, 1);
      expect(groupedFamilies.isNotEmpty, true);
      expect(e, isA<TypeError>());
    });

    test('handles empty results correctly', () async {
      // Arrange
      when(mockDatabaseHelper.queryAbhadithaFamilies())
          .thenAnswer((_) async => []);

      // Act
      await screenState.fetchAbhadithaFamilies();

      // Assert
      expect(screenState.groupedAbhadithaFamilies.isEmpty, true);
    });
  });
}
