// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/home.dart';
import 'package:skyewooapp/screens/payment_browser.dart';
import 'package:skyewooapp/site.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({Key? key}) : super(key: key);

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  //session
  UserSession userSession = UserSession();

  //controlls
  TextEditingController couponController = TextEditingController();

  //defaults
  String firstLastName = "First and Last Name";
  String address1 = "Address 1";
  String address2 = "Address 2";
  String cityStateCountry = "City State, Country";
  String phone = "Phone";
  String email = "Email";
  String subtotal = "0";
  String couponDiscount = "0";
  String total = "0";
  String flatRateLPrice = "0";
  String localPickupPrice = "0";
  String selectedShipping = "";
  bool flatRateAvailable = true;
  bool localPickupAvailable = true;
  bool freeShippingAvailable = true;
  bool couponAvailable = false;
  bool hasShipping = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await userSession.init();
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // Add Your Code here.
        fetchCart();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Payment Checkout"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "YOUR ADDRESS",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.hover,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstLastName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cityStateCountry,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "HAVE COUPON?",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.hover),
                    bottom: BorderSide(color: AppColors.hover),
                  ),
                ),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: InputForm(
                          controller: couponController,
                          hintText: "Coupon Code (if any)",
                          fontSize: 16,
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 2,
                          ),
                          backgroundColor: AppColors.f1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: TextButton(
                        style: AppStyles.flatButtonStyle(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                        ),
                        child: const Text("Apply"),
                        onPressed: () {
                          applyCoupon();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "YOUR ORDER",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.hover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          Site.CURRENCY + Formatter.format(subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.hover),
                    const SizedBox(height: 10),
                    //coupon discount
                    Visibility(
                      visible: couponAvailable,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Coupon Discount",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "-" +
                                    Site.CURRENCY +
                                    Formatter.format(couponDiscount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.hover),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    //shipping
                    Visibility(
                      visible: hasShipping,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shipping",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.hover,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //flat rate
                                Visibility(
                                  visible: flatRateAvailable,
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: "flat_rate",
                                        groupValue: selectedShipping,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedShipping = value!;
                                            changeShipmentMethod(
                                                selectedShipping);
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          children: <TextSpan>[
                                            const TextSpan(
                                                text:
                                                    "SHIPPING (1-3 DAYS)    "),
                                            TextSpan(
                                              text: Site.CURRENCY +
                                                  Formatter.format(
                                                      flatRateLPrice),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //local pickup
                                Visibility(
                                  visible: localPickupAvailable,
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: "local_pickup",
                                        groupValue: selectedShipping,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedShipping = value!;
                                            changeShipmentMethod(
                                                selectedShipping);
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          children: <TextSpan>[
                                            const TextSpan(
                                                text: "LOCAL PICKUP    "),
                                            TextSpan(
                                              text: Site.CURRENCY +
                                                  Formatter.format(
                                                      localPickupPrice),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //free shipping
                                Visibility(
                                  visible: freeShippingAvailable,
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: "free_shipping",
                                        groupValue: selectedShipping,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedShipping = value!;
                                            changeShipmentMethod(
                                                selectedShipping);
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      const Text(
                                        "FREE SHIPPING",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          Site.CURRENCY + Formatter.format(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                style: AppStyles.flatButtonStyle(),
                onPressed: () {
                  createOrder("web", "pedning");
                },
                child: const Text(
                  "CONFIRM & PAY",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  fetchCart() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);

    //fetch
    String url = Site.CART + userSession.ID + "?token_key=" + Site.TOKEN_KEY;
    Response response = await get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(response.body);
      if (json.containsKey("items")) {
        if (List.from(json["items"]).isNotEmpty) {
          //
          subtotal = json["subtotal"].toString();
          total = json["total"].toString();

          if (json["has_coupon"].toString() == "true") {
            couponDiscount = json["coupon_discount"].toString();
            couponAvailable = true;
            Toaster.show(message: "Coupon Applied");
          } else {
            couponAvailable = false;
          }

          //shipping
          if (json["has_shipping"].toString() == "true") {
            Map<String, dynamic> shippingMethods = json["shipping_methods"];

            if (shippingMethods.containsKey("flat_rate")) {
              Map<String, dynamic> flatRate = shippingMethods["flat_rate"];
              flatRateAvailable = true;
              flatRateLPrice = flatRate["cost"].toString();
            } else {
              flatRateAvailable = false;
            }

            if (shippingMethods.containsKey("local_pickup")) {
              Map<String, dynamic> localPickup =
                  shippingMethods["local_pickup"];
              localPickupAvailable = true;
              localPickupPrice = localPickup["cost"].toString();
            } else {
              localPickupAvailable = false;
            }

            if (shippingMethods.containsKey("free_shipping")) {
              // Map<String, dynamic> free_shipping = shippingMethods["free_shipping"];
              freeShippingAvailable = true;
            } else {
              freeShippingAvailable = false;
            }

            //auto select the shipping method of which user has in database
            if (json.containsKey("shipping_method")) {
              if (json["shipping_method"].toString() == "flat_rate") {
                selectedShipping = "flat_rate";
              }
              if (json["shipping_method"].toString() == "local_pickup") {
                selectedShipping = "local_pickup";
              }
              if (json["shipping_method"].toString() == "free_shipping") {
                selectedShipping = "free_shipping";
              }
            }
          } else {
            hasShipping = false;
          }

          //FOR WHATSDOWN ONLY
          if (double.parse(json["total"].toString()) >= 500) {
            Map<String, dynamic> shippingMethods = json["shipping_methods"];
            if (shippingMethods.containsKey("free_shipping")) {
              selectedShipping = "free_shipping";
              freeShippingAvailable = true;
              await changeShippingMethod("free_shipping");
            }
          } else {
            freeShippingAvailable = false;
          }

          fetchAddress();
        } else {
          cartIsEmpty();
        }
      } else {
        cartIsEmpty();
      }
    } else {
      Toaster.show(message: "Unable to get your cart.");
      Navigator.pop(context);
    }
  }

  cartIsEmpty() {
    Toaster.show(message: "Your Cart is empty.");
    Navigator.pop(context);
  }

  changeShipmentMethod(String method) async {
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    await changeShippingMethod(method);
    SmartDialog.dismiss();
    setState(() {});
  }

  changeShippingMethod(String method) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      //fetch
      String url = Site.CHANGE_CART_SHIPPING + userSession.ID + "/" + method;
      dynamic data = {
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json["has_shipping"].toString() == "true") {
          // double subtotalDouble = double.parse(json["subtotal"].toString());
          // double totalDouble = double.parse(json["total"].toString());
          // double couponDiscountDouble = double.parse(json["coupon_discount"].toString());
          subtotal = json["subtotal"].toString();
          couponDiscount = json["coupon_discount"].toString();
          total = json["total"].toString();
          Toaster.show(
              message: "Shipping method updated", gravity: ToastGravity.TOP);
        } else {
          Toaster.show(
              message: "Cart has no shipping go back and update your address!");
        }
      } else {
        Toaster.show(message: "Unable to update shipping method!");
      }
    } finally {}
  }

  fetchAddress() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      String url = Site.USER +
          userSession.ID +
          "?with_regions=1" +
          Site.TOKEN_KEY_APPEND;
      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Map<String, dynamic> address = json["shipping_address"];
        firstLastName = address["shipping_first_name"].toString() +
            " " +
            address["shipping_last_name"].toString();
        address1 = address["shipping_address_1"].toString();
        address2 = address["shipping_address_2"].toString();
        cityStateCountry = address["shipping_city"].toString() +
            " " +
            address["shipping_state"].toString() +
            ", " +
            address["shipping_country"].toString();
        phone = address["shipping_phone"].toString();
        email = address["shipping_email"].toString();

        //end
      } else {
        Toaster.show(message: "Can't get your address, Try again");
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        SmartDialog.dismiss();
        setState(() {});
      }
    }
  }

  applyCoupon() async {
    FocusScope.of(context).unfocus();
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);

    String coupon = couponController.text;

    //fetch
    try {
      String url = Site.UPDATE_COUPON + userSession.ID + "/" + coupon;
      dynamic data = {
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json["has_coupon"].toString() == "true") {
          couponAvailable = true;
          couponDiscount = json["coupon_discount"].toString();
          Toaster.show(message: "Coupon Applied");
        } else {
          Toaster.show(message: "Invalid Coupon!");
          couponAvailable = false;
        }

        subtotal = json["subtotal"].toString();
        total = json["total"].toString();

        //end
      } else {
        Toaster.show(message: "Unable to apply coupon.");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }

  createOrder(String paymentMethod, String status) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }

    SmartDialog.show(
        widget: const LoadingBox(text: "Creating Order..."),
        clickBgDismissTemp: false);

    try {
      //fetch
      String url = Site.CREATE_ORDER + userSession.ID;
      dynamic data = {
        "token_key=": Site.TOKEN_KEY,
      };
      if (paymentMethod != "web") {
        data["payment_method"] = paymentMethod;
      }
      if (paymentMethod != "paypal") {
        data["clear_cart"] = "1";
      }

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json["cart_empty"].toString() == "true" ||
            json["cart_exists"].toString() == "false" ||
            !json.containsKey("info")) {
          //
          Toaster.show(
            message: "Cannot create order because cart is empty or not found.",
            gravity: ToastGravity.TOP,
          );
        } else {
          //order created
          //we are using web payment method only in this app
          // if (paymentMethod == "web" || ) {
          //get pending payment url and parse to payment browser
          Map<String, dynamic> info = json["info"];
          String checkoutURL = info["checkout_payment_url"].toString();
          checkoutURL += "&sk-web-payment=1&sk-user-checkout=" + userSession.ID;
          checkoutURL += "&in_sk_app=1";
          checkoutURL +=
              "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";

          //push
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentBrowser(
                url: checkoutURL,
              ),
            ),
          ).then((value) {
            //pop to root
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(
                    navigateTo: "orders",
                    title: Site
                        .NAME, //home page header title - not orders page title
                  ),
                ),
                (route) => false);
          });
          // }

        }

        //end
      } else {
        Toaster.show(message: "Unable to create order... Try Again");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }
}
