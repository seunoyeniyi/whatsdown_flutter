// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/site.dart';

class ProductsController extends GetxController {
  var userSession = UserSession().obs;
  var isLoading = true.obs;
  var gotToEnd = false.obs;
  var products = <Product>[].obs;
  var messages = <String>[].obs;
  String order_by = "title menu_order";
  String paged = "1";
  int currentPaged = 1;
  String numPerPage = "40";
  bool forWishlist = false;
  var search = "".obs;
  bool initialize = true;

  //filter
  String selected_category = "";
  String selected_tag = "";
  String selected_color = "";
  RangeValues? priceRange;

  ProductsController({
    this.initialize = true,
    bool isLoading = true,
    this.forWishlist = false, //for wishlist page
    this.selected_category = "", //for archive page
    this.order_by = "title menu_order",
    this.numPerPage = "40",
  }) {
    this.isLoading.value = isLoading;
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    await userSession.value.init();
    if (initialize) {
      fetchProducts();
    }
  }

  void fetchProducts({bool append = true}) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      messages.add("Bad Internet connection");
      return;
    }

    try {
      isLoading(true);
      messages.clear(); //clear messages first;
      if (append == false) {
        //clear products, paged, currentPaged and add new
        products.clear();
        paged = "1";
        currentPaged = 1;
        gotToEnd.value = false;
      }

      String url = Site.SIMPLE_PRODUCTS +
          "?orderby=" +
          order_by +
          "&per_page=" +
          numPerPage +
          "&hide_description=1" +
          "&user_id=" +
          userSession.value.ID +
          "&paged=" +
          paged +
          "&token_key=" +
          Site.TOKEN_KEY;

      switch (order_by) {
        case "price":
          url = Site.SIMPLE_PRODUCTS +
              "?orderby=meta_value_num&meta_key=_price&order=asc&per_page=" +
              numPerPage +
              "&hide_description=1" +
              "&user_id=" +
              userSession.value.ID +
              "&paged=" +
              paged +
              "&token_key=" +
              Site.TOKEN_KEY;
          break;
        case "price-desc":
          url = Site.SIMPLE_PRODUCTS +
              "?orderby=meta_value_num&meta_key=_price&order=desc&per_page=" +
              numPerPage +
              "&hide_description=1" +
              "&user_id=" +
              userSession.value.ID +
              "&paged=" +
              paged +
              "&token_key=" +
              Site.TOKEN_KEY;
          break;
        case "date":
          url = Site.SIMPLE_PRODUCTS +
              "?orderby=date&order=DESC&per_page=" +
              numPerPage +
              "&hide_description=1" +
              "&user_id=" +
              userSession.value.ID +
              "&paged=" +
              paged +
              "&token_key=" +
              Site.TOKEN_KEY;
          break;
        default:
          break;
      }

      if (selected_category.isNotEmpty) {
        url += "&cat=" + selected_category;
      }

      if (selected_tag.isNotEmpty) {
        url += "&tag=" + selected_tag;
      }

      if (selected_color.isNotEmpty) {
        url += "&color=" + selected_color;
      }

      if (priceRange != null) {
        url = Site.SIMPLE_PRODUCTS +
            "?price_range=" +
            priceRange!.start.round().toString() +
            "|" +
            priceRange!.end.round().toString() +
            "&per_page=" +
            numPerPage +
            "&hide_description=1" +
            "&user_id=" +
            userSession.value.ID +
            "&paged=" +
            paged +
            "&token_key=" +
            Site.TOKEN_KEY;
      }

      if (search.value.isNotEmpty) {
        url = url + "&search=" + search.value;
      }

      if (forWishlist) {
        url = Site.WISH_LIST +
            userSession.value.ID +
            "?hide_description=1" +
            "&token_key=" +
            Site.TOKEN_KEY;
      }

      Response response = await get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> json =
            jsonDecode(response.body.isEmpty ? "{}" : response.body);
        if (json.isNotEmpty) {
          List<Map<String, dynamic>> results = List.from(json["results"]);

          if (append == false && results.isEmpty) {
            messages.add("No Result");
            // Toast.show(context, "No Result", title: "No Products");
          }

          for (var item in results) {
            // log("image: " + item["image"].toString());
            Product product = Product();
            product.setID = item["ID"].toString();
            product.setName = item["name"].toString();
            product.setImage = item["image"].toString();
            product.setPrice = item["price"].toString();
            product.setRegularPrice = item["regular_price"].toString();
            product.setType = item["type"].toString();
            product.setProductType = item["product_type"].toString();
            product.setDescription = item["description"].toString();
            product.setInWishList = item["in_wishlist"].toString();
            product.setCategories = item["categories"].toString();
            product.setStockStatus = item["stock_status"].toString();
            product.setLowestPrice = item["lowest_variation_price"].toString();
            product.setHighestPrice =
                item["highest_variation_price"].toString();

            products.add(product);
          }

          //update wishlist count if is forWishlist
          if (forWishlist) {
            await userSession.value
                .update_last_wishlist_count(results.length.toString());
          }

          if (json.containsKey("pagination")) {
            if (json["pagination"] != null) {
              currentPaged = int.parse(json["paged"]);
            }
          }
        } else {
          if (products.isEmpty) {
            messages.add("No result");
          } else {
            gotToEnd.value = true;
            messages.add("No more result");
          }
        }
      } else {
        messages.add("Oops.. Error communication");
      }
    } finally {
      isLoading(false);
    }
  }
}
