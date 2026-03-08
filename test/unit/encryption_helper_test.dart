import 'package:flutter_test/flutter_test.dart';
import 'package:employee_connect/core/utils/encryption_helper.dart';

void main() {
  group('EncryptionHelper Tests', () {
    test('Encryption and Decryption should be consistent', () {
      const plainText = 'Hello Employee Connect';
      
      final encrypted = EncryptionHelper.encrypt(plainText);
      final decrypted = EncryptionHelper.decrypt(encrypted);
      
      expect(decrypted, plainText);
      expect(encrypted, isNot(plainText));
    });

    test('Different texts result in different encryptions', () {
      const text1 = 'Test 1';
      const text2 = 'Test 2';
      
      final enc1 = EncryptionHelper.encrypt(text1);
      final enc2 = EncryptionHelper.encrypt(text2);
      
      expect(enc1, isNot(enc2));
    });

    test('Encryption should return a base64 string', () {
      const plainText = 'Some text';
      final encrypted = EncryptionHelper.encrypt(plainText);
      
      // Basic base64 regex check
      final base64Regex = RegExp(r'^[a-zA-Z0-9+/]*={0,2}$');
      expect(base64Regex.hasMatch(encrypted), isTrue);
    });
  });
}
