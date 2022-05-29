import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    final isAvaliable = await hasBimetric();
    try {
      return await _auth.authenticate(
        localizedReason: 'Local auth to access the system',
        options: AuthenticationOptions(useErrorDialogs: true, stickyAuth: true),
      );
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<bool> hasBimetric() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }
}
