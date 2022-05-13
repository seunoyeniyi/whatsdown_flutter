import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/site.dart';

class Wishlist {
  final UserSession userSession;

  Wishlist({required this.userSession});

  Future<bool> update(String userID, String productID, String action) async {
    bool updated = false;

    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return updated;
    }

    String url = Site.ADD_TO_WISH_LIST + userID + "/" + productID;
    if (action == "remove") {
      url = Site.REMOVE_FROM_WISH_LIST + userID + "/" + productID;
    }

    url = url + "?token_key=" + Site.TOKEN_KEY;

    Response response = await post(url);

    if (response.statusCode == 200) {
      updated = true;
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> results = List.from(json["results"]);

      if (action == "add") {
        updated = (results.isNotEmpty);
      }

      userSession.update_last_wishlist_count(results.length.toString());
    }

    return updated;
  }
}
