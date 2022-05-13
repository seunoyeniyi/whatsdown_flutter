import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/cart_item.dart';
import 'package:skyewooapp/site.dart';

class CartsController extends GetxController {
  var userSession = UserSession().obs;
  var isLoading = true.obs;
  var items = <CartItem>[].obs;
  var messages = <String>[].obs;
  var hasNewCustomerOffer = false.obs;
  var topMessages = <String>[].obs;
  var subtotal = "0".obs;
  var total = "0".obs;
  var couponDiscount = "0".obs;
  var hasCoupon = false.obs;
  var checkoutEnabled = false.obs;
  var totalLoading = false.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    await userSession.value.init();
    fetchCart();
  }

  void fetchCart() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      messages.add("Bad Internet connection");
      return;
    }

    try {
      isLoading.value = true;
      items.clear();
      messages.clear();
      topMessages.clear();
      //fetch
      String url =
          Site.CART + userSession.value.ID + "?token_key=" + Site.TOKEN_KEY;
      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<Map<String, dynamic>> jsonItems = List.from(json["items"]);
        if (jsonItems.isEmpty) {
          messages.add("Your cart is empty");
        }
        if (json.containsKey("is_new_customer")) {
          if (json["is_new_customer"].toString() == "true" &&
              json["has_coupon"].toString() == "true") {
            topMessages.add("10% OFF applied as a New Customer");
          }
        }

        for (var item in jsonItems) {
          String usedTitle = item["product_title"].toString();
          if (item["product_type"].toString() == "wooco") {
            usedTitle = "Combo - " + item["product_title"].toString();
          }
          items.add(CartItem(
            id: item["ID"].toString(),
            name: usedTitle,
            quantity: item["quantity"].toString(),
            price: item["price"].toString(),
            image: item["product_image"].toString(),
            productType: item["product_type"].toString(),
          ));
        }

        subtotal.value = json["subtotal"].toString();

        double subtotalDouble = double.parse(json["subtotal"].toString());
        double couponDiscountDouble = 0;
        double rewardDiscountDouble = 0;

        if (json["has_coupon"].toString() == "true") {
          couponDiscountDouble =
              double.parse(json["coupon_discount"].toString());
          couponDiscount.value = json["coupon_discount"].toString();
          messages.add("Coupon Applied");
        }
        if (json["apply_reward"].toString() == "true") {
          rewardDiscountDouble =
              double.parse(json["reward_discount"].toString());
        }
        total.value =
            (subtotalDouble - couponDiscountDouble - rewardDiscountDouble)
                .toString();

        hasCoupon.value = json["has_coupon"].toString() == "true";

        checkoutEnabled.value = double.parse(json["subtotal"].toString()) > 0;

        await userSession.value
            .update_last_cart_count(json["contents_count"].toString());

        //end
      } else {
        messages.add("Unable to get Cart");
      }
    } finally {
      isLoading.value = false;
      totalLoading.value = false;
    }
  }

  void updateCartItem(int itemPosition, int quantity) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      messages.add("Bad Internet connection");
      return;
    }

    totalLoading.value = true;
    messages.clear();
    topMessages.clear();
    //frist get the product id from the itemPosition
    String productID = items[itemPosition].getID;
    //then remove item if quantity is less than zero
    if (quantity < 1) {
      items.removeAt(itemPosition);
    }
    //NOTE: never use itemPosition again after this line, bacuse the positon has been removed, if used, app will crash

    try {
      //fetch
      String url = Site.ADD_TO_CART + productID;
      dynamic data = {
        "user": userSession.value.ID,
        "quantity": quantity.toString(),
        "replace_quantity":
            "1", //since this is a quantity replacement from single cart item
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey("user_cart_not_exists")) {
          messages.add("Can't create cart! Please login or register.");
        } else {
          //good to go
          List<Map<String, dynamic>> jsonItems = List.from(json["items"]);
          if (jsonItems.isEmpty) {
            messages.add("Your cart is empty");
          }

          if (json.containsKey("is_new_customer")) {
            if (json["is_new_customer"].toString() == "true" &&
                json["has_coupon"].toString() == "true") {
              topMessages.add("10% OFF applied as a New Customer");
            }
          }

          //we are not adding to items again, just update and removal
          // for (var item in jsonItems) {
          //   items.add(CartItem(
          //     id: item["ID"].toString(),
          //     name: item["product_title"].toString(),
          //     quantity: item["quantity"].toString(),
          //     price: item["price"].toString(),
          //     image: item["product_image"].toString(),
          //     productType: item["product_type"].toString(),
          //   ));
          // }

          subtotal.value = json["subtotal"].toString();
          double subtotalDouble = double.parse(json["subtotal"].toString());
          double couponDiscountDouble = 0;
          double rewardDiscountDouble = 0;

          if (json["has_coupon"].toString() == "true") {
            couponDiscountDouble =
                double.parse(json["coupon_discount"].toString());
          }
          if (json["apply_reward"].toString() == "true") {
            rewardDiscountDouble =
                double.parse(json["reward_discount"].toString());
          }
          total.value =
              (subtotalDouble - couponDiscountDouble - rewardDiscountDouble)
                  .toString();

          hasCoupon.value = json["has_coupon"].toString() == "true";

          checkoutEnabled.value = double.parse(json["subtotal"].toString()) > 0;

          await userSession.value
              .update_last_cart_count(json["contents_count"].toString());
        }

        //end
      } else {
        messages.add("Unable to update cart item");
      }
    } finally {
      totalLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> applyCoupon(String coupon) async {
    bool applied = false;
    String message = "";

    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      message = "Bad Internet connection";
      return {
        "applied": applied,
        "message": message,
      };
    }

    //fetch
    String url = Site.UPDATE_COUPON + userSession.value.ID + "/" + coupon;
    dynamic data = {
      "token_key": Site.TOKEN_KEY,
    };

    Response response = await post(url, body: data);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(response.body);

      double subtotalDouble = double.parse(json["subtotal"].toString());
      double couponDiscountDouble = 0;
      double rewardDiscountDouble = 0;

      if (json["has_coupon"].toString() == "true") {
        hasCoupon.value = true;
        couponDiscountDouble = double.parse(json["coupon_discount"].toString());
        //shipping cost might have been added (so, total will be calculated here) - after getting out of this condition at the bottom

        couponDiscount.value = json["coupon_discount"].toString();
        message = "Coupon Applied";
      } else {
        message = "Invalid Coupon!";
        hasCoupon.value = false;
      }

      subtotal.value = json["subtotal"].toString();
      //calculate total
      total.value =
          (subtotalDouble - couponDiscountDouble - rewardDiscountDouble)
              .toString();

      //end
    } else {
      message = "Unable to apply coupon.";
    }

    return {
      "applied": applied,
      "message": message,
    };
  }
}
