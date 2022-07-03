// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:skyewooapp/handlers/site_info.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/home.dart';
import 'package:skyewooapp/site.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  SiteInfo siteInfo = SiteInfo();
  UserSession userSession = UserSession();

  AnimationController? _animeController;

  init() async {
    await userSession.init();
    await siteInfo.init();

    updateOneSignal(); //asynchronously

    await checkSiteSettings();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: Site.NAME,
          ),
        ),
        (route) => false);

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MyHomePage(
    //       title: Site.NAME,
    //     ),
    //   ),
    // );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    _animeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animeController!.forward();
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_animeController!),
            child: Image.asset(
              "assets/images/logo.png",
              height: 80,
              width: 80,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animeController!.dispose();
    super.dispose();
  }

  Future<void> checkSiteSettings() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }
    try {
      //fetch
      String url = Site.INFO + "?token_key=" + Site.TOKEN_KEY;
      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> site = jsonDecode(response.body);

        siteInfo.set("name", site["name"].toString());
        siteInfo.set_banner_enable_value(
            "slide", site["enable_slide_banners"].toString() == "1");
        siteInfo.set_banner_enable_value(
            "big", site["enable_big_banners"].toString() == "1");
        siteInfo.set_banner_enable_value(
            "carousel", site["enable_carousel_banners"].toString() == "1");
        siteInfo.set_banner_enable_value(
            "thin", site["enable_thin_banners"].toString() == "1");
//                    siteInfo.set_banner_enable_value("sale", site["enable_sale_banners"].toString() == "1");
        siteInfo.set_banner_enable_value(
            "grid", site["enable_grid_banners"].toString() == "1");
        siteInfo.set_banner_enable_value(
            "video", site["enable_video_banners"].toString() == "1");
        siteInfo.setSplashLogo(site["app_splash_logo"].toString());
        siteInfo.setMainLogo(site["app_main_logo"].toString());

        siteInfo.set_last_check(DateTime.now().millisecondsSinceEpoch);
      } else {
        //nothing
      }
    } finally {}
  }

  Future<void> updateOneSignal() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }

    final status = await OneSignal.shared.getDeviceState();
    final String? userID = status?.userId;
    // final String? token = status?.pushToken; //can't use because we have to seperate android and ios token in rest api

    if (userID != null) {
      //save to server
      try {
        UserSession userSession = UserSession();
        await userSession.init();
        //fetch
        String url =
            Site.ADD_DEVICE + userSession.ID + "?token_key=" + Site.TOKEN_KEY;

        dynamic data = {
          "device": userID,
        };

        Response response = await post(url, body: data);

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          //nothing
          // log(response.body);
        } else {
          //nothing
        }
      } finally {
        //nothing
      }
    }
  }
}
