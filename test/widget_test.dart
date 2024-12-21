import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:village_officer_app/family_member_form.dart';

void main() {
  testWidgets('FamilyMemberForm smoke test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FamilyMemberForm(),
        ),
      ),
    );

    // Verify the expected text is present
    expect(find.text('Number of Family Members'), findsOneWidget);
  });
}
