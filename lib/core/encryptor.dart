import 'package:encrypt/encrypt.dart';

class Encryptor {
  Encrypter get encrypter {
    return Encrypter(AES(key));
  }

  Key get key {
    return Key.fromUtf8('c56a2a6101d44d05b89543ba409b9acf');
  }

  IV get iv {
    return IV.fromLength(16);
  }

  String encrypt(String decrypted) {
    return encrypter.encrypt(decrypted, iv: iv).base64;
  }

  String decrypt(String encrypted) {
    return encrypter.decrypt64(encrypted, iv: iv);
  }
}
