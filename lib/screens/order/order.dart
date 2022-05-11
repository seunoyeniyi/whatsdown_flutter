import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_html/flutter_html.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/order_item.dart';
import 'package:skyewooapp/screens/browser.dart';
import 'package:skyewooapp/screens/order/order_details_card.dart';
import 'package:skyewooapp/screens/order/shimmer.dart';
import 'package:skyewooapp/screens/payment_browser.dart';
import 'package:skyewooapp/site.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;
const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);

final _processes = [
  'Received',
  'Processed',
  'Shipped',
  'Out for delivery',
  'Delivered',
];

class OrderPage extends StatefulWidget {
  const OrderPage({
    Key? key,
    required this.orderID,
  }) : super(key: key);

  final String orderID;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  UserSession userSession = UserSession();
  bool isLoading = true;
  bool hasResult = true;

  //ORDER DETAILS
  String orderStatus = "Unknown status";
  String orderInfo = "";
  List<OrderItem> orderItems = [];
  String orderSubtotal = "0";
  String orderDiscount = "0";
  String orderShippingMethod = "";
  String orderTotalAmount = "0";
  String email = "";
  String fullName = "";
  String company = "";
  String address1 = "";
  String city = "";
  String state = "";
  String postcode = "";
  String address2 = "";
  String phone = "";
  String country = "";
  bool trackingAvailable = false;
  String trackingProvider = "";
  String trackingNumber = "";
  String trackingLink = "";
  bool isPendingPayment = false;
  String checkoutUrl = "";
  //END ORDER DETAILS

  int _processIndex = 0;

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  init() async {
    await userSession.init();
    fetchDetails();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.f1,
      appBar: AppBar(
        title: Text("Order #" + widget.orderID),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 20,
              bottom: 20,
            ),
            child: (() {
              if (isLoading) {
                return const OrderPageShimmer();
              } else if (!isLoading && !hasResult) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        fetchDetails();
                      },
                      child: const Text("Try Again"),
                    ),
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //paynow
                    Visibility(
                      visible: isPendingPayment,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 5,
                                  top: 5,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                //push
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentBrowser(
                                      url: checkoutUrl,
                                      from: "order",
                                    ),
                                  ),
                                ).then((value) {
                                  fetchDetails();
                                });
                              },
                              child: const Text("PAY NOW"),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    //order info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.hover,
                        ),
                      ),
                      width: double.infinity,
                      child: Text(
                        orderInfo,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //order process timeline
                    Container(
                      color: Colors.white,
                      height: 100,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 0, right: 10, bottom: 20, left: 0),
                      child: Timeline.tileBuilder(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        theme: TimelineThemeData(
                          direction: Axis.horizontal,
                          connectorTheme: const ConnectorThemeData(
                            space: 30.0,
                            thickness: 5.0,
                          ),
                        ),
                        builder: TimelineTileBuilder.connected(
                          connectionDirection: ConnectionDirection.before,
                          itemExtentBuilder: (_, __) =>
                              (MediaQuery.of(context).size.width /
                                  _processes.length) -
                              5,
                          contentsBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                _processes[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: getColor(index),
                                  fontSize: 8,
                                ),
                              ),
                            );
                          },
                          indicatorBuilder: (_, index) {
                            // ignore: prefer_typing_uninitialized_variables
                            var color;
                            // ignore: prefer_typing_uninitialized_variables
                            var child;
                            if (index == _processIndex) {
                              color = inProgressColor;
                              child = const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.pending,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                              );
                            } else if (index < _processIndex) {
                              color = completeColor;
                              child = const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 15.0,
                              );
                            } else {
                              color = todoColor;
                            }

                            if (index <= _processIndex) {
                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(30.0, 30.0),
                                    painter: _BezierPainter(
                                      color: color,
                                      drawStart: index > 0,
                                      drawEnd: index < _processIndex,
                                    ),
                                  ),
                                  DotIndicator(
                                    size: 30.0,
                                    color: color,
                                    child: child,
                                  ),
                                ],
                              );
                            } else {
                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(15.0, 15.0),
                                    painter: _BezierPainter(
                                      color: color,
                                      drawEnd: index < _processes.length - 1,
                                    ),
                                  ),
                                  OutlinedDotIndicator(
                                    borderWidth: 4.0,
                                    color: color,
                                  ),
                                ],
                              );
                            }
                          },
                          connectorBuilder: (_, index, type) {
                            if (index > 0) {
                              if (index == _processIndex) {
                                final prevColor = getColor(index - 1);
                                final color = getColor(index);
                                List<Color> gradientColors;
                                if (type == ConnectorType.start) {
                                  gradientColors = [
                                    Color.lerp(prevColor, color, 0.5)!,
                                    color
                                  ];
                                } else {
                                  gradientColors = [
                                    prevColor,
                                    Color.lerp(prevColor, color, 0.5)!
                                  ];
                                }
                                return DecoratedLineConnector(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                    ),
                                  ),
                                );
                              } else {
                                return SolidLineConnector(
                                  color: getColor(index),
                                );
                              }
                            } else {
                              return null;
                            }
                          },
                          itemCount: _processes.length,
                        ),
                      ),
                    ),
                    //order details text
                    const SizedBox(height: 20),
                    const Text(
                      "Order details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    //order items (details)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.hover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(orderItems.length, (index) {
                          return OrderDetailsCard(
                            quantity: orderItems[index].getQuantity,
                            name: orderItems[index].getName,
                            amount: orderItems[index].getAmount,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //order price table
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
                                Site.CURRENCY + Formatter.format(orderSubtotal),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Discount",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                Site.CURRENCY + Formatter.format(orderDiscount),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Shipping",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                child: Html(
                                  shrinkToFit: true,
                                  data: orderShippingMethod,
                                  defaultTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  customTextAlign: (element) {
                                    return TextAlign.right;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.hover),
                          const SizedBox(height: 10),
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
                                Site.CURRENCY +
                                    Formatter.format(orderTotalAmount),
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
                    const SizedBox(height: 10),
                    //shipping address
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.hover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shipping",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                    const SizedBox(width: 80),
                                    Text(
                                      trackingProvider,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          //tracking button
                          Center(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(30),
                                  padding: const EdgeInsets.all(10),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.pin_drop),
                                label: const Text("TRACK ORDER"),
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
                                    Toaster.show(
                                        message:
                                            "Your order is not yet picked.");
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(email),
                          const SizedBox(height: 10),
                          Text(fullName),
                          const SizedBox(height: 10),
                          Text(company),
                          const SizedBox(height: 10),
                          Text(address1),
                          const SizedBox(height: 10),
                          Text(address2),
                          const SizedBox(height: 10),
                          Text(city),
                          const SizedBox(height: 10),
                          Text(state),
                          const SizedBox(height: 10),
                          Text(postcode),
                          const SizedBox(height: 10),
                          Text(country),
                          const SizedBox(height: 10),
                          Text(phone),
                        ],
                      ),
                    ),
                    //end column
                  ],
                );
              }
            }()),
          ),
        ),
      ),
    );
  }

  fetchDetails() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      //fetch
      String url = Site.ORDER +
          widget.orderID +
          "/" +
          userSession.ID +
          "?token_key=" +
          Site.TOKEN_KEY;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey("code") && json["data"].toString() == "null") {
          Toaster.show(message: json["message"].toString());
          hasResult = false;
        } else {
          hasResult = true;
          switch (json["status"].toString()) {
            case "pending":
              orderStatus = "Pending payment";
              break;
            case "processing":
              orderStatus = "Processing";
              _processIndex = 2;
              break;
            case "shipped":
              orderStatus = "Shipped";
              _processIndex = 4;
              break;
            case "completed":
              orderStatus = "Completed";
              _processIndex = 5;
              break;
            case "on-hold":
              orderStatus = "On hold";
              break;
            case "cancelled":
              orderStatus = "Cancelled";
              break;
            case "refunded":
              orderStatus = "Refunded";
              break;
            default:
              break;
          }
          if (json["payment_method"].toString() == "paypal" &&
              json["status"].toString() == "on-hold") {
            orderStatus = "Paypal Cancelled";
          }

          orderInfo = "Order #" +
              json["ID"].toString() +
              " was placed on " +
              json["date_modified_date"].toString() +
              " and is currently " +
              orderStatus +
              ".";

          //order items
          orderItems.clear();
          List<Map<String, dynamic>> jsonItems = List.from(json["products"]);
          for (var item in jsonItems) {
            orderItems.add(OrderItem(
              name: item["name"].toString(),
              quantity: item["quantity"].toString(),
              amount: item["subtotal"].toString(),
            ));
          }

          //order prices table
          orderSubtotal = json["subtotal"].toString();
          double subtotalDouble = double.parse(json["subtotal"].toString());
          double totalDouble = double.parse(json["total"].toString());
          double discountTotal = totalDouble - subtotalDouble;

          orderDiscount = ((discountTotal < 0) ? discountTotal : 0).toString();

          orderShippingMethod = json["shipping_to_display"].toString();

          orderTotalAmount = json["total"].toString();

          //if pending payment
          if (json["status"].toString() == "pending") {
            isPendingPayment = true;
            checkoutUrl = json["checkout_payment_url"].toString();
            if (json["payment_method"].toString() == "stripe_cc" ||
                json["payment_method"].toString() == "stripe") {
              checkoutUrl +=
                  "&sk-web-payment=1&sk-stripe-checkout=1&sk-user-checkout=" +
                      userSession.ID;
            } else {
              checkoutUrl +=
                  "&sk-web-payment=1&sk-user-checkout=" + userSession.ID;
            }
            checkoutUrl += "&in_sk_app=1";
            checkoutUrl +=
                "&hide_elements=div*topbar.topbar, div.joinchat__button, *notificationx-frontend-root";
          } else {
            isPendingPayment = false;
          }

          //shipping info
          fullName = json["shipping_first_name"].toString() +
              " " +
              json["shipping_last_name"].toString();
          company = json["shipping_company"].toString();
          address1 = json["shipping_address_1"].toString();
          address2 = json["shipping_address_2"].toString();
          city = json["shipping_city"].toString();
          state = json["shipping_state"].toString();
          postcode = json["shipping_postcode"].toString();
          country = json["shipping_country"].toString();
          phone = json["billing_phone"].toString();
          email = json["billing_email"].toString();

          //shipment tracking
          if (json.containsKey("zorem_tracking_items")) {
            List<Map<String, dynamic>> shippingItems =
                List.from(json["zorem_tracking_items"]);
            if (shippingItems.isNotEmpty) {
              trackingAvailable = true;
              var shipment = shippingItems[0];
              trackingProvider =
                  shipment["formatted_tracking_provider"].toString();
              trackingNumber = shipment["tracking_number"].toString();
              trackingLink = shipment["ast_tracking_link"].toString();
            }
          }
          //end
        }
      } else {
        Toaster.show(message: "No result... This order could not be yours");
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

/// hardcoded bezier painter
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    // ignore: prefer_typing_uninitialized_variables
    var angle;
    // ignore: prefer_typing_uninitialized_variables
    var offset1;
    // ignore: prefer_typing_uninitialized_variables
    var offset2;

    // ignore: prefer_typing_uninitialized_variables
    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius)
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(
            size.width, size.height / 2, size.width + radius, radius)
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
