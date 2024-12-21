import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:village_officer_app/Abhadhitha.dart';
import 'package:village_officer_app/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite_common_ffi for database access during tests.
  testWidgets('shows empty state when no data is available',
      (WidgetTester tester) async {
    // Initialize the database factory to use ffi.
    databaseFactory = databaseFactoryFfi;

    // Build the widget tree for the test.
    await tester.pumpWidget(MaterialApp(
      home: AbhadithaFamiliesScreen(),
    ));

    // Wait for all the animations to complete.
    await tester.pumpAndSettle();

    // Ensure that the "No data available" message is shown when there are no families.
    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('renders PDF generation button and displays message when tapped',
      (WidgetTester tester) async {
    // Initialize the database factory to use ffi.
    databaseFactory = databaseFactoryFfi;

    // Build the widget tree for the test.
    await tester.pumpWidget(MaterialApp(
      home: AbhadithaFamiliesScreen(),
    ));

    // Wait for all the animations to complete.
    await tester.pumpAndSettle();

    // Ensure that the PDF generation button is rendered.
    expect(find.text('Generate PDF'), findsOneWidget);

    // Tap the PDF generation button and wait for the changes to be reflected.
    await tester.tap(find.text('Generate PDF'));
    await tester.pumpAndSettle();

    // Ensure that the message for PDF generation is displayed.
    expect(find.text('PDF Generation in progress...'), findsOneWidget);
  });
}
