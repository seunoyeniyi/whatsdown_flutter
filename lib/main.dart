import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/screens/account/account.dart';
import 'package:skyewooapp/screens/cart/cart_page.dart';
import 'package:skyewooapp/screens/categories/categories.dart';
import 'package:skyewooapp/screens/checkout_address/checkout_address.dart';
import 'package:skyewooapp/screens/orders/orders.dart';
import 'package:skyewooapp/screens/payment_checkout/payment_checkout.dart';
import 'package:skyewooapp/screens/wishlist/wishlist_page.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/home/home.dart';
import 'package:skyewooapp/screens/login/login_screen.dart';
import 'package:skyewooapp/screens/signup/signup_screen.dart';
import 'package:skyewooapp/screens/welcome/welcome_screen.dart';
import 'package:skyewooapp/ui/app_bar.dart';
import 'package:skyewooapp/ui/app_drawer.dart';
import 'package:skyewooapp/ui/shop/shop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Site.NAME,
      theme: ThemeData(
        fontFamily: "Montserrat",
        primarySwatch: AppColors.primarySwatch,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      home: MyHomePage(title: Site.NAME),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, this.navigateTo = ""})
      : super(key: key);

  final String title;
  final String navigateTo;

  //SETUP STATIC FUNCTIONS
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyHomePageState>()!.restartApp();
  }

  static void changeBody(BuildContext context, int body) {
    context.findAncestorStateOfType<_MyHomePageState>()!.changeBody(body);
  }

  static void upateAppBarWishlistBadge(BuildContext context, String count) {
    context
        .findAncestorStateOfType<_MyHomePageState>()!
        .upateAppBarWishlistBadge(count);
  }

  static void upateAppBarWCartCount(BuildContext context, String count) {
    context
        .findAncestorStateOfType<_MyHomePageState>()!
        .upateAppBarWCartCount(count);
  }

  static void showSearchBar(BuildContext context) {
    context.findAncestorStateOfType<_MyHomePageState>()!.showSearchBar();
  }

  static void resetAppBar(BuildContext context) {
    context.findAncestorStateOfType<_MyHomePageState>()!.resetAppBar();
  }

  //END STATIC FUNCTIONS

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserSession userSession = UserSession();
  AppAppBarController appBarController = AppAppBarController();

  Key? key = UniqueKey();

  final List<Widget> bodies = [
    const HomeBody(key: PageStorageKey("HomeBody")),
  ];
  int _bodyIndex = 0;

  init() async {
    await userSession.init();
    //if not logged
    if (!userSession.logged()) {
      Navigator.pushNamed(context, "welcome");
    }
    //add shop body
    bodies.add(ShopBody(
      key: const PageStorageKey("ShopBody"),
      appBarController: appBarController,
    ));

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.navigateTo == "orders") {
        Navigator.pushNamed(context, "orders");
      }
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void restartApp() {
    setState(() {
      key = UniqueKey();
      resetAppBar();
    });
  }

  void changeBody(int body) {
    setState(() {
      if (bodies.asMap().containsKey(body)) {
        _bodyIndex = body;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          controller: appBarController,
        ),
        drawer: const AppDrawer(),
        body: bodies[_bodyIndex],
        // IndexedStack(
        //   index: _bodyIndex,
        //   children: bodies,
        // ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void upateAppBarWishlistBadge(String count) {
    if (appBarController.updateWishlistBadge != null) {
      appBarController.updateWishlistBadge!(count);
    }
  }

  void upateAppBarWCartCount(String count) {
    if (appBarController.updateCartCount != null) {
      appBarController.updateCartCount!(count);
    }
  }

  void showSearchBar() {
    if (appBarController.displaySearch != null) {
      appBarController.displaySearch!();
    }
  }

  void resetAppBar() {
    if (appBarController.refreshAll != null) {
      appBarController.refreshAll!();
    }
  }
}
