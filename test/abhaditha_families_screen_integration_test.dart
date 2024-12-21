import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:village_officer_app/Abhadhitha.dart';
import 'package:village_officer_app/database_helper.dart';

import 'package:path_provider/path_provider.dart';
import 'package:village_officer_app/family_member.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AbhadithaFamiliesScreen Integration Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Clear existing data
      await dbHelper.queryAbhadithaFamilies().then((families) async {
        for (var family in families) {
          await dbHelper.deleteFamilyMemberById(family['nationalId']);
        }
      });
    });

    testWidgets('Shows empty state message when no families exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No data available for Disability Aid recipients.'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Displays correct family information and counts',
        (WidgetTester tester) async {
      // Insert test data
      final testMembers = [
        {
          'householdNumber': 'H123',
          'name': 'John Doe',
          'nationalId': '123456789',
          'age': 45,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        },
        {
          'householdNumber': 'H123',
          'name': 'Jane Doe',
          'nationalId': '987654321',
          'age': 40,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        }
      ];

      for (var member in testMembers) {
        await dbHelper.insertFamilyMember(member as FamilyMember);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AppBar title and counts
      expect(find.text('Disability Aid receivers'), findsOneWidget);
      expect(find.text('1 Family | 2 Family Members'), findsOneWidget);

      // Verify household information
      expect(find.text('1. Household Number: H123'), findsOneWidget);
      expect(find.text('Members: 2'), findsOneWidget);
    });

    testWidgets('ExpansionTile shows member details correctly',
        (WidgetTester tester) async {
      // Insert test data
      final member = {
        'householdNumber': 'H123',
        'name': 'John Doe',
        'nationalId': '123456789',
        'age': 45,
        'familyHeadType': 'Family Head - Male',
        'dateOfModified': '2024-03-20',
      };

      await dbHelper.insertFamilyMember(member as FamilyMember);

      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially, details should be hidden
      expect(find.text('National ID: 123456789'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('1. Household Number: H123'));
      await tester.pumpAndSettle();

      // Verify member details are visible
      expect(find.text('1st: John Doe'), findsOneWidget);
      expect(find.text('National ID: 123456789'), findsOneWidget);
    });

    testWidgets('PDF generation functionality', (WidgetTester tester) async {
      // Insert test data
      final member = {
        'householdNumber': 'H123',
        'name': 'John Doe',
        'nationalId': '123456789',
        'age': 45,
        'familyHeadType': 'Family Head - Male',
        'dateOfModified': '2024-03-20',
      };

      await dbHelper.insertFamilyMember(member as FamilyMember);

      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify PDF button exists
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

      // Tap PDF button
      await tester.tap(find.byIcon(Icons.picture_as_pdf));
      await tester.pumpAndSettle();

      // Verify SnackBar appears (success or error message)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Ordinal numbers are displayed correctly',
        (WidgetTester tester) async {
      // Insert multiple members
      final testMembers = [
        {
          'householdNumber': 'H123',
          'name': 'First Person',
          'nationalId': '111111111',
          'age': 45,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        },
        {
          'householdNumber': 'H123',
          'name': 'Second Person',
          'nationalId': '222222222',
          'age': 40,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        },
        {
          'householdNumber': 'H123',
          'name': 'Third Person',
          'nationalId': '333333333',
          'age': 15,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        }
      ];

      for (var member in testMembers) {
        await dbHelper.insertFamilyMember(member as FamilyMember);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the household
      await tester.tap(find.text('1. Household Number: H123'));
      await tester.pumpAndSettle();

      // Verify ordinal numbers
      expect(find.text('1st: First Person'), findsOneWidget);
      expect(find.text('2nd: Second Person'), findsOneWidget);
      expect(find.text('3rd: Third Person'), findsOneWidget);
    });

    testWidgets('Multiple households are displayed correctly',
        (WidgetTester tester) async {
      // Insert members from different households
      final testMembers = [
        {
          'householdNumber': 'H123',
          'name': 'John Doe',
          'nationalId': '111111111',
          'age': 45,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        },
        {
          'householdNumber': 'H456',
          'name': 'Jane Smith',
          'nationalId': '222222222',
          'age': 40,
          'familyHeadType': 'Family Head - Male',
          'dateOfModified': '2024-03-20',
        }
      ];

      for (var member in testMembers) {
        await dbHelper.insertFamilyMember(member as FamilyMember);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: AbhadithaFamiliesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify both households are displayed
      expect(find.text('1. Household Number: H123'), findsOneWidget);
      expect(find.text('2. Household Number: H456'), findsOneWidget);
      expect(find.text('2 Families | 2 Family Members'), findsOneWidget);
    });
  });
}
