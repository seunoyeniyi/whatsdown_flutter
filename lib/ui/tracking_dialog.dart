import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/screens/browser.dart';
import 'package:skyewooapp/site.dart';

class TrackingDialog extends StatefulWidget {
  const TrackingDialog({Key? key}) : super(key: key);

  @override
  State<TrackingDialog> createState() => _TrackingDialogState();
}

class _TrackingDialogState extends State<TrackingDialog> {
  UserSession userSession = UserSession();
  bool isLoading = false;
  bool trackingAvailable = false;
  String trackingProvider = "";
  String trackingNumber = "";
  String trackingLink = "";
  var idController = TextEditingController();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await userSession.init();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //title
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/icons8_track_order_1.svg",
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Track your Order",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    //
                    const SizedBox(height: 20),
                    //input box
                    Visibility(
                      visible: !trackingAvailable,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Order ID",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          InputForm(
                            hintText: "Enter your Order ID",
                            controller: idController,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    //tracking info
                    Visibility(
                      visible: trackingAvailable,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Provider:",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 30),
                              Text(
                                trackingProvider,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Text(
                                "Tracking Number:",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 30),
                              Text(
                                trackingNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    //button
                    TextButton(
                      style: AppStyles.flatButtonStyle(
                        backgroundColor: trackingAvailable
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      onPressed: () {
                        if (trackingAvailable) {
                          //push
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppBrowser(
                                title: "Track Order",
                                url: trackingLink,
                              ),
                            ),
                          );
                        } else {
                          trackOrder();
                        }
                      },
                      child: Text(
                        trackingAvailable ? "Track" : "Next",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Visibility(
                  visible: isLoading,
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  trackOrder() async {
    FocusScope.of(context).unfocus();
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      //fetch
      String url = Site.ORDER + idController.text + "/" + userSession.ID;
      Response response = await get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey("code") && json["data"].toString() == "null") {
          Toaster.show(message: json["message"].toString());
        } else {
          if (json.containsKey("zorem_tracking_items")) {
            List<Map<String, dynamic>> shippingItems =
                List.from(json["zorem_tracking_items"]);
            if (shippingItems.isNotEmpty) {
              Map<String, dynamic> shipment = shippingItems[0];
              trackingLink = shipment["ast_tracking_link"].toString();
              trackingProvider =
                  shipment["formatted_tracking_provider"].toString();
              trackingNumber = shipment["tracking_number"].toString();
              trackingAvailable = true;
            } else {
              Toaster.show(message: "Order is not yet picked.");
            }
          } else {
            Toaster.show(message: "Order is not yet picked.");
          }
        }
      } else {
        Toaster.show(message: "Unable to get order");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
