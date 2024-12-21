import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_helper.dart';

class LicenseManager {
  static const _storedLicenseKey = "stored_license_key";
  static const _validLicenseKey =
      "1234-5678-9101-1121"; // Replace with your valid key

  /// Checks if the app is already activated

  static Future<bool> isAppActivated() async {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(_storedLicenseKey);

    if (storedKey == null) return false;

    // Decrypt and compare the stored key
    final decryptedKey = EncryptionHelper.decrypt(storedKey);
    return decryptedKey == _validLicenseKey;
  }

  /// Validates the license key and stores it
  static Future<bool> validateAndStoreKey(String userKey) async {
    if (userKey == _validLicenseKey) {
      final prefs = await SharedPreferences.getInstance();
      final encryptedKey = EncryptionHelper.encrypt(userKey);
      await prefs.setString(_storedLicenseKey, encryptedKey);
      return true;
    }
    return false;
  }
}
