import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/screens/account/account.dart';
import 'package:skyewooapp/screens/cart/cart_page.dart';
import 'package:skyewooapp/screens/categories/categories.dart';
import 'package:skyewooapp/screens/checkout_address/checkout_address.dart';
import 'package:skyewooapp/screens/orders/orders.dart';
import 'package:skyewooapp/screens/payment_checkout/payment_checkout.dart';
import 'package:skyewooapp/screens/wishlist/wishlist_page.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/splash_screen.dart';
import 'package:skyewooapp/screens/login/login_screen.dart';
import 'package:skyewooapp/screens/signup/signup_screen.dart';
import 'package:skyewooapp/screens/welcome/welcome_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Site.NAME,
      theme: ThemeData(
        fontFamily: "Montserrat",
        primarySwatch: AppColors.primarySwatch,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      home: const SplashScreen(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      routes: {
        "welcome": (BuildContext context) => const WelcomeScreen(),
        "login": (BuildContext context) => const LoginScreen(),
        "register": (BuildContext context) => const SignUpScreen(),
        "cart": (BuildContext context) => const CartPage(),
        "wishlist": (BuildContext context) => const WishlistPage(),
        "categories": (BuildContext context) => const CategoriesPage(),
        "orders": (BuildContext context) => const OrdersPage(),
        "account": (BuildContext context) => const AccountPage(),
        "checkout_address": (BuildContext context) =>
            const CheckoutAddressPage(),
        "payment_checkout": (BuildContext context) =>
            const PaymentCheckoutPage(),
      },
    );
  }
}
