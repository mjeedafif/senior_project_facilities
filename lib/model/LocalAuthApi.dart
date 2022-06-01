import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/Auth.dart';
import '../provider/Prefs.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();
  static SharedPreferences? _prefs;

  static Future<Map<String, dynamic>> authenticate() async {
    final isAvaliable = await hasBimetric();
    Map<String, dynamic> data = {'email': '', 'password': ''};
    //_prefs = await Prefs.init();
    _prefs = await Prefs.init();
    try {
      var isAutherized = await _auth.authenticate(
        localizedReason: 'Local auth to access the system',
        options: AuthenticationOptions(useErrorDialogs: true, stickyAuth: true),
      );
      if (isAutherized) {
        //Get the data
        String? email = _prefs!.getString('email');
        String? password = _prefs!.getString('password');
        print('email: $email');
        print('password: $password');
        data = {
          'email': email,
          'password': password,
        };
        return data;
      }
    } on PlatformException catch (e) {
      return data;
    }
    return data;
  }

  static Future<bool> hasBimetric() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }
}
