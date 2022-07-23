import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/firebase_options.dart';
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
  //initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //initialize awsoome notification
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for AreaHire',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  init() async {
    NotificationSettings _ = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    //AWESOME LOCAL NOTIFICATION
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // subscribe to topic on each app start-up
    await FirebaseMessaging.instance.subscribeToTopic('general');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //customer parsed data
      // var customData = message.data;

      if (message.notification != null) {
        var data = message.notification!.toMap();
        NotificationContent content = NotificationContent(
          id: 0,
          channelKey: 'basic_channel',
          title: message.notification?.title,
          body: message.notification?.body,
          displayOnBackground: true,
          showWhen: true,
        );

        //check for image
        var bigPicture = "";
        if (data["android"] != null) {
          var android = data["android"];
          if (android.containsKey("imageUrl")) {
            if (android["imageUrl"] != null) {
              bigPicture = android["imageUrl"];
            }
          }
        } else if (Platform.isIOS) {
          if (data["apple"] != null) {
            var apple = data["apple"];
            if (apple.containsKey("imageUrl")) {
              if (apple["imageUrl"] != null) {
                bigPicture = apple["imageUrl"];
              }
            }
          }
        }

        //add image
        if (bigPicture.toString().length > 10) {
          content.bigPicture = bigPicture
              .toString(); //still not showing awesomenotifications issue
          content.notificationLayout = NotificationLayout.BigPicture;
        }

        // log(data.toString());

        AwesomeNotifications().createNotification(
          content: content,
        );
      }
    });

    setupNotificationInteraction();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  setupNotificationInteraction() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationRoute(initialMessage);
    }
    //also listin to message opened
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationRoute);
  }

  handleNotificationRoute(RemoteMessage message) {
    // var data = message.data;
    //todo later;
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

// Declared as global, outside of any class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  // var customData = message.data;

  // Use this method to automatically convert the push data, in case you gonna use our data standard
  // AwesomeNotifications().createNotificationFromJsonData(message.data); //firebase display notification itself
}
