import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:employee_connect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Verify Initial Screen (License Activation or Home)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check if we start at License Activation or Home
      final bool isLicensePage = find.text('License Activation').evaluate().isNotEmpty;
      final bool isHomePage = find.text('Number of Family Members').evaluate().isNotEmpty;

      expect(isLicensePage || isHomePage, isTrue, reason: 'Should be either on License Page or Home Page');
    });
  });
}
