import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Language with ChangeNotifier {
  String _locale = 'en';

  void changeLanguage(String lan, BuildContext context) {
    if (lan == 'العربية') {
      _locale = 'ar';
    } else {
      _locale = 'en';
    }
    notifyListeners();
  }

  String get locale => _locale;
}
