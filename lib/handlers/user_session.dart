// ignore_for_file: non_constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  String ID = "0";
  String username = "";
  String email = "";
  String last_orders_count = "0";
  String last_cart_count = "0";
  String last_wishlist_count = "0";
  int date = DateTime.now().millisecondsSinceEpoch;
  bool _logged = false;
  String profile_image = "";

  UserSession() {
    init();
  }

  Future<void> init() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    ID = pref.getString("ID") ?? "0";
    username = pref.getString("username") ?? "";
    email = pref.getString("email") ?? "";
    date = pref.getInt("date") ?? DateTime.now().microsecondsSinceEpoch;
    _logged = pref.getBool("logged") ?? false;
    last_orders_count = pref.getString("last_orders_count") ?? "0";
    last_cart_count = pref.getString("last_cart_count") ?? "0";
    last_wishlist_count = pref.getString("last_wishlist_count") ?? "0";
    profile_image = pref.getString("profile_image") ?? "";
  }

  Future<void> reload() async {
    await init();
  }

  Future<void> createLoginSession(
      {required String userID,
      required String xusername,
      required String xemail,
      required bool logged}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    ID = userID;
    username = xusername;
    email = xemail;
    date = DateTime.now().microsecondsSinceEpoch;

    prefs.setString("ID", userID);
    prefs.setString("username", xusername);
    prefs.setString("email", xemail);
    prefs.setInt("date", DateTime.now().microsecondsSinceEpoch);
    prefs.setBool("logged", logged);
  }

  Future<Map<String, dynamic>> getDetails() async {
    await init();
    Map<String, dynamic> data = {
      "ID": ID,
      "username": username,
      "email": email,
      "date": date,
      "logged": logged,
      "last_orders_count": last_orders_count,
      "last_cart_count": last_cart_count,
      "last_wishlist_count": last_wishlist_count,
      "profile_image": profile_image
    };
    return data;
  }

  Future<void> update_profile_image(String image) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("profile_image", image);
    profile_image = image;
  }

  Future<void> update_last_orders_count(String count) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("last_orders_count", count);
    last_orders_count = count;
  }

  Future<void> update_last_cart_count(String count) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("last_cart_count", count);
    last_cart_count = count;
  }

  Future<void> update_last_wishlist_count(String count) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("last_wishlist_count", count);
    last_wishlist_count = count;
  }

  bool logged() {
    init();
    return (_logged && ID != "0");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    reload();
  }
}
