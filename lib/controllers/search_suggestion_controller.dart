// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/site.dart';

class SuggestionController extends GetxController {
  var isLoading = false.obs;
  var products = <Product>[].obs;
  var search = "".obs;

  ProductsController() {
    //clear result first
    products.clear();
  }

  void fetchProducts() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }

    try {
      isLoading(true);

      products.clear();

      String url = Site.SEARCH + "?s=" + search.value + "&show_image=1";

      Response response = await get(url);
      //add default - search query
      Product defaultP = Product();
      defaultP.id = "0";
      defaultP.name = search.value;
      defaultP.image = "";
      products.add(defaultP);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> json = jsonDecode(response.body);

        for (Map<String, dynamic> item in json) {
          Product product = Product();
          product.id = item["ID"].toString();
          product.name = item["name"].toString();
          product.image = item["image"].toString();
          products.add(product);
        }
      }
    } finally {
      isLoading(false);
    }
  }
}
