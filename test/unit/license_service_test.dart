import 'package:flutter_test/flutter_test.dart';
import 'package:employee_connect/data/services/license_service.dart';
import 'package:employee_connect/core/utils/encryption_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LicenseManager Tests', () {
    const validKey = "1234-5678-9101-1121";

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('App is not activated initially', () async {
      final isActivated = await LicenseManager.isAppActivated();
      expect(isActivated, isFalse);
    });

    test('Validating and storing a correct key should work', () async {
      final result = await LicenseManager.validateAndStoreKey(validKey);
      expect(result, isTrue);

      final isActivated = await LicenseManager.isAppActivated();
      expect(isActivated, isTrue);
    });

    test('Validating an incorrect key should fail', () async {
      final result = await LicenseManager.validateAndStoreKey("WRONG-KEY-0000");
      expect(result, isFalse);

      final isActivated = await LicenseManager.isAppActivated();
      expect(isActivated, isFalse);
    });

    test('Stored key is properly encrypted in SharedPreferences', () async {
      await LicenseManager.validateAndStoreKey(validKey);
      
      final prefs = await SharedPreferences.getInstance();
      final storedValue = prefs.getString("stored_license_key");
      
      expect(storedValue, isNotNull);
      expect(storedValue, isNot(validKey));
      
      // Verify it can be decrypted to the valid key
      final decrypted = EncryptionHelper.decrypt(storedValue!);
      expect(decrypted, validKey);
    });
  });
}
