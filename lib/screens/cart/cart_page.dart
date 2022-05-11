import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/controllers/carts_controller.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/screens/cart/cart_card.dart';
import 'package:skyewooapp/screens/cart/shimmer.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/app_bar.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  UserSession userSession = UserSession();
  AppAppBarController appBarController = AppAppBarController();
  CartsController cartsController = Get.put(CartsController());

  TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await userSession.init();
    Get.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        titleType: "title",
        title: "Cart",
        hasSearch: false,
        hasWishlist: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.vertical,
        child: Obx(() {
          if (cartsController.messages.isNotEmpty) {
            for (var message in cartsController.messages) {
              Toaster.show(message: message);
            }
            cartsController.messages.clear();
          }
          if (appBarController.updateCartCount != null) {
            appBarController
                .updateCartCount!(cartsController.items.length.toString());
          }
          if (cartsController.isLoading.value) {
            return const CartPageShimmer();
          } else if (!cartsController.isLoading.value &&
              cartsController.items.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 40,
                  bottom: 10,
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Cart Empty",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.hover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        child: const Text("Try Again"),
                        onPressed: () {
                          cartsController.fetchCart();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  //top alert messages
                  Column(
                    children: List.generate(cartsController.topMessages.length,
                        (index) {
                      return Container(
                        color: AppColors.primary,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 1),
                        child: Center(
                          child: Html(
                            data: cartsController.topMessages[index],
                            defaultTextStyle: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 12,
                            ),
                            customTextAlign: (element) {
                              return TextAlign.center;
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  //cart items
                  Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Column(
                      children:
                          List.generate(cartsController.items.length, (index) {
                        return CartCard(
                          item: cartsController.items[index],
                          onChanged: (int quantity) {
                            cartsController.updateCartItem(index, quantity);
                          },
                        );
                      }),
                    ),
                  ),
                  //coupon text field container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.hover,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
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
                  const SizedBox(height: 10),
                  //total price table
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.hover,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //subotal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Subotal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      Site.CURRENCY +
                                          Formatter.format(
                                              cartsController.subtotal.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            //coupon discount
                            Visibility(
                              visible: cartsController.hasCoupon.value,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "Coupon",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "-" +
                                                Site.CURRENCY +
                                                Formatter.format(cartsController
                                                    .couponDiscount.value),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //total
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      Site.CURRENCY +
                                          Formatter.format(
                                              cartsController.total.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            //checkout button
                            TextButton(
                              style: AppStyles.flatButtonStyle(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                              ),
                              child: const Text("CHECKOUT"),
                              onPressed: () {
                                if (cartsController.checkoutEnabled.value) {
                                  Navigator.pushNamed(
                                          context, "checkout_address")
                                      .then((value) {
                                    cartsController.fetchCart();
                                  });
                                } else {
                                  Toaster.show(
                                      message:
                                          "Something is wrong, please go back and try again.");
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      //total loading progress
                      Positioned.fill(
                        child: Visibility(
                          visible: cartsController.totalLoading.value,
                          child: Container(
                            color: Colors.white.withOpacity(0.8),
                            padding: const EdgeInsets.only(bottom: 50),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.hover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  //continue shopping button
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                      style: AppStyles.flatButtonStyle(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        backgroundColor: Colors.white,
                        primary: AppColors.primary,
                      ),
                      child: const Text("CONTINUE SHOPPING"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }
        }),
      ),
    );
  }

  applyCoupon() async {
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);

    Map<String, dynamic> result =
        await cartsController.applyCoupon(couponController.text);

    if (result["message"].toString().isNotEmpty) {
      Toaster.show(
        message: result["message"].toString(),
        gravity: ToastGravity.TOP,
      );
    }

    SmartDialog.dismiss();
  }
}
