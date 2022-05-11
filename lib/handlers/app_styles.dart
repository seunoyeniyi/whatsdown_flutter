import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';

class AppStyles {
  static ButtonStyle flatButtonStyle({
    Key? key,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15),
    Color backgroundColor = AppColors.primary,
    Size minimumSize = const Size.fromHeight(30),
    Color primary = AppColors.onPrimary,
    double radius = 3,
  }) {
    return TextButton.styleFrom(
      primary: primary,
      minimumSize: minimumSize,
      backgroundColor: backgroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }

  static ButtonStyle inlineFlatButtonStyle({
    Key? key,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15),
    Color backgroundColor = AppColors.primary,
    Color primary = AppColors.onPrimary,
    double radius = 3,
  }) {
    return TextButton.styleFrom(
      primary: primary,
      backgroundColor: backgroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }
}
