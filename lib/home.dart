// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/ui/home/home.dart';
import 'package:skyewooapp/ui/app_bar.dart';
import 'package:skyewooapp/ui/app_drawer.dart';
import 'package:skyewooapp/ui/shop/shop.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
    return Scaffold(
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
