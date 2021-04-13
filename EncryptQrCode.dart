import 'package:encrypt/encrypt.dart';

class EncryptQrCode{
  final String customer;
  final String shop;
  final String userkey;
  final String what;

  const EncryptQrCode({key,this.customer,this.userkey,this.shop,this.what }) ;


  showData() {
    final plainText = 'intellixsoft:'+customer+":"+userkey+":"+shop+":"+what;
    //final key = Key.fromUtf8('');
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    print(" Source ");
    //print(encrypted.bytes);
    // print(encrypted.base16);
    print(encrypted.base64);
    print("Decrypth Plaintext "+decrypted);
    return encrypted.base64;
  }

}


class DecryptQrCode{
  final String ecdata;
  DecryptQrCode({key,this.ecdata }) ;
  Encrypted ecdatac;

  showData() {

    //final plainText = 'intellixsoft:'+customer+":"+userkey+":"+shop+":"+what;
    //final key = Key.fromUtf8('');
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
   // final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt64(ecdata, iv: iv);
    print(" Source ");
    //print(encrypted.bytes);
    // print(encrypted.base16);
    print("Decrypth Plaintext "+decrypted);
    return decrypted;
  }

}