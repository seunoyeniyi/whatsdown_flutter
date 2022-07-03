import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  //Remove this method to stop OneSignal Debugging
  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("3e4c9692-4d12-4031-8a35-313cc1ffb718");

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    //log("Accepted permission: $accepted");
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  init() async {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      // Will be called whenever a notification is received in foreground
      //log("message received in foreground");
      // Display Notification, pass null param for not displaying the notification
      event.complete(event.notification);
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
      //log("message opened");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes

      // log("user subscription changed");

      // (ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges emailChanges) {
      // Will be called whenever then user's email subscription changes
      //log("user email subscription changed");
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

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
