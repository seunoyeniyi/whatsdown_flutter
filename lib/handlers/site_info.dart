// ignore_for_file: non_constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyewooapp/site.dart';

class SiteInfo {
  String name = Site.NAME;

  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name = preferences.getString("name") ?? Site.NAME;
  }

  Future<void> set(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, value);
  }

  Future<bool> is_banner_enabled(String banner) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("banner_" + banner) ??
        (banner == "slide"); //default is true for slide banner
  }

  Future<void> set_banner_enable_value(String banner, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("banner_" + banner, value);
  }

  Future<void> enable_banner(String banner) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("banner_" + banner, true);
  }

  Future<void> disable_banner(String banner) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("banner_" + banner, false);
  }

  Future<void> set_last_check(int last) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("last_check", last);
  }

  Future<int> get_last_check() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt("last_check") ?? 0;
  }
}
