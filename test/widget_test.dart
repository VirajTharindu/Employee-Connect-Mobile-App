import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:village_officer_app/main.dart';
import 'package:village_officer_app/family_member_form.dart';

void main() {
  testWidgets('FamilyMemberForm smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VillageOfficerApp());

    // Verify that the main form fields are present.
    expect(find.text('Number of Family Members'), findsOneWidget);
    expect(find.text('Save Family Data'), findsOneWidget);

    // Enter text in the 'Number of Family Members' field.
    await tester.enterText(find.byType(TextFormField).first, '3');
    await tester.pump();

    // Verify the entered text.
    expect(find.text('3'), findsOneWidget);

    // Tap the 'Save Family Data' button.
    await tester.tap(find.text('Save Family Data'));
    await tester.pump();

    // Since there's no actual functionality here, we can assume success if no errors occur.
  });
}
