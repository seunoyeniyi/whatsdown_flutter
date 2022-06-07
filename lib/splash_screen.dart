// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/firebase_options.dart';
import 'package:skyewooapp/handlers/site_info.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/home.dart';
import 'package:skyewooapp/services/push_notificaton.dart';
import 'package:skyewooapp/site.dart';

GetIt locator = GetIt.instance;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  PushNotificationService? _pushNotificationService;
  SiteInfo siteInfo = SiteInfo();
  UserSession userSession = UserSession();

  AnimationController? _animeController;

  init() async {
    await userSession.init();
    await siteInfo.init();
    //initialize firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //register services before app start
    locator.registerLazySingleton(() => PushNotificationService());

    //add Push Notifications to GetIT
    _pushNotificationService = locator<PushNotificationService>();

    // Register for push notifications
    if (_pushNotificationService != null) {
      await _pushNotificationService?.initialize();
    }

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
}
