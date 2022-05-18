import 'package:flutter/material.dart';

class ConstColors {
  //Stackoverflow code to take a color integer in primarySwatch
  static MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    // ignore: avoid_function_literals_in_foreach_calls
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static const Color widgetColor = Color(0xffFAFFF8);
  static const Color textFieldsColor = Color(0xffEFFFE9);
  static const Color borderTextFieldsColor = Color(0xff99F674);
  static const Color borderColor = Color(0xffC2C2C2);
  static const Color borderSelectColor = Color(0xffC4C4C4);
  static const Color textButtonColor = Color(0xff68B84D);
  static const Color borderCategory = Color(0xff99F674);
  static const Color backButtonColor = Color(0xffBEE5B0);
  static const Color helpColor = Color(0xffB0E19F);
  static const Color logoutColor = Color(0xffE19F9F);
  static const Color selectedColor = Color(0xff047701);
  static const Color primaryColor = Color(0xffBBD57C);
  static const Color backgroundColor = Color(0xfff5fff3);
}
