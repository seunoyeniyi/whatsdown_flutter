import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF000000);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryHover = Color(0xFF312F2F);
  static const primaryLight = Color.fromARGB(255, 173, 173, 173);
  static const primaryInputLight = Color.fromARGB(255, 238, 238, 238);
  static const secondary = Color(0xFFFF6962);
  static const secondaryLight = Color.fromARGB(255, 255, 158, 153);
  static const secondary2 = Color(0xFF5E6BD8);
  static const link = Color.fromARGB(255, 110, 110, 110);
  static const f1 = Color(0xFFF1F1F1);
  static const hover = Color(0xFFC5C5C5);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const primarySwatch = appPrimarySwatch;
}

const MaterialColor appPrimarySwatch = MaterialColor(
  _appPrimarySwatchValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_appPrimarySwatchValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _appPrimarySwatchValue = 0xFF000000;
