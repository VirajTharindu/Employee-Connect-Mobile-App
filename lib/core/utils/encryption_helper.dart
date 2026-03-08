import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  // Use a 32-byte key (256 bits)
  static final key = Key.fromUtf8('12345678901234567890123456789012');
  static final iv = IV.fromLength(16); // 16-byte IV

  /// Encrypts a plain text string
  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /// Decrypts an encrypted text string
  static String decrypt(String encryptedText) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
