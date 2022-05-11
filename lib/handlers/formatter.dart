// ignore_for_file: file_names

import 'package:intl/intl.dart';

import 'handlers.dart';

class Formatter {
  static String format(dynamic num) {
    if (num.toString().isNotEmpty && isNumeric(num.toString())) {
      var money = NumberFormat("#,##0.00", "en_US");
      return money.format(double.parse(num.toString()));
    } else {
      return "0";
    }
  }
}
