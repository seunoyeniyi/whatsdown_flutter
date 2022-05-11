import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skyewooapp/app_colors.dart';

class ToastBar {
  static void show(BuildContext context, String message,
      {String title = "Alert",
      FlushbarPosition position = FlushbarPosition.TOP,
      int duration = 3}) {
    Flushbar(
      flushbarPosition: position,
      title: title,
      message: message,
      duration: Duration(seconds: duration),
    ).show(context);
  }
}

class Toaster {
  static void show({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_LONG,
    Color background = AppColors.primary,
    Color textColor = AppColors.onPrimary,
    double fontSize = 16.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: background,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  static void showIcon({
    required String message,
    required IconData icon,
    required BuildContext context,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int duration = 2,
    Color background = AppColors.primary,
    Color textColor = AppColors.onPrimary,
    double fontSize = 16.0,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    double radius = 25.0,
  }) {
    FToast fToast = FToast(context);
    Widget toast = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12.0),
          Text(message,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              )),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: gravity,
      toastDuration: Duration(seconds: duration),
    );
  }
}

class AppRoute {
  static String getName(BuildContext context) {
    if (ModalRoute.of(context) != null) {
      return ModalRoute.of(context)!.settings.name ?? "";
    } else {
      return "";
    }
  }
}

bool isNumeric(String str) {
  return double.tryParse(str) != null;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

bool isValidEmail(String val) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(val);
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
