import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/order.dart';
import 'package:skyewooapp/screens/order/order.dart';
import 'package:skyewooapp/screens/orders/order_card.dart';
import 'package:skyewooapp/screens/orders/shimmer.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/app_bar.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key, this.status = "all"}) : super(key: key);

  final String status;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  AppAppBarController appBarController = AppAppBarController();
  UserSession userSession = UserSession();

  String status = "all";
  bool isLoading = true;
  List<Order> orders = [];

  // List of items in our dropdown menu
  int sortIndex = 0;
  List<OrderSort> sortItems = [
    OrderSort(name: "all", title: 'All'),
    OrderSort(name: "processing", title: 'Processing'),
    OrderSort(name: "pending", title: 'Pending Payment'),
    OrderSort(name: "completed", title: 'Completed'),
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await userSession.init();
    status = widget.status;
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.f1,
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        titleType: "title",
        title: "Orders",
        hasCart: false,
        hasSearch: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Material(
              //HEADER FILTER
              elevation: 1,
              child: Container(
                padding: const EdgeInsets.all(0),
                width: double.infinity,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: AppColors.f1),
                      bottom: BorderSide(color: AppColors.f1)),
                ),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<OrderSort>(
                    isExpanded: true,
                    value: sortItems[sortIndex],
                    icon: const Icon(Icons.arrow_drop_down),
                    items: sortItems.map((OrderSort item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sortIndex = sortItems.indexOf(value!);
                        status = value.getName;
                        fetchOrders();
                      });
                    },
                    underline: const SizedBox(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                scrollDirection: Axis.vertical,
                child: Container(
                  color: Colors.white,
                  child: (() {
                    if (isLoading && orders.isEmpty) {
                      return const OrdersPageShimmer();
                    } else if (!isLoading && orders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "No order found!",
                                style: TextStyle(
                                  color: AppColors.link,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  child: const Text("Try Again"),
                                  onPressed: () {
                                    fetchOrders();
                                  }),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(orders.length, (index) {
                            return OrderCard(
                              orderID: orders[index].getId,
                              date: orders[index].getDate,
                              status: orders[index].getStatus,
                              paymentMethod: orders[index].getPaymentMethod,
                              amount: orders[index].getAmount,
                              onTapped: () {
                                //push
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderPage(
                                      orderID: orders[index].getId,
                                    ),
                                  ),
                                ).then((value) {
                                  fetchOrders();
                                });
                              },
                            );
                          }),
                        ),
                      );
                    }
                  }()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  fetchOrders() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      setState(() {
        isLoading = true;
        orders.clear();
      });
      //fetch
      String url =
          Site.ORDERS + userSession.ID + "?token_key=" + Site.TOKEN_KEY;
      switch (status) {
        case "complete":
        case "completed":
        case "wc-completed":
          url += "&status=wc-completed";
          break;
        case "processing":
        case "wc-processing":
          url += "&status=wc-processing";
          break;
        case "pending":
        case "wc-pending":
          url += "&status=wc-pending";
          break;
        case "wc-on-hold":
        case "on-hold":
          url += "&status=wc-on-hold";
          break;
        default:
          break;
      }

      Response response = await get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<Map<String, dynamic>> jsonOrders = List.from(json["orders"]);

        orders.clear();
        for (var order in jsonOrders) {
          orders.add(Order(
            id: order["ID"].toString(),
            date: order["date_modified_date"].toString(),
            status: order["status"].toString(),
            paymentMethod: order["payment_method"].toString(),
            amount: order["total"].toString(),
          ));
        }

        if (jsonOrders.isEmpty) {
          Toaster.show(message: "No result");
        }
      } else {
        Toaster.show(message: "Unable to get orders... Please try again");
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

class OrderSort {
  String name;
  String title;

  OrderSort({required this.name, required this.title});

  String get getName => name;

  set setName(String name) => this.name = name;

  String get getTitle => title;

  set setTitle(title) => this.title = title;
}
