import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_connect/presentation/pages/auth/license_activation_page.dart';

void main() {
  testWidgets('LicenseActivationPage UI Test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: LicenseActivationPage(),
      ),
    );

    // Verify Title
    expect(find.text('License Activation'), findsOneWidget);

    // Verify Input Field
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('License Key'), findsOneWidget);

    // Verify Button
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Activate Now'), findsOneWidget);
  });
}
