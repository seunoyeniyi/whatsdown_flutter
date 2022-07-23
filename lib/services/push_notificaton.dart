// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/site.dart';

// local notification functions
void selectNotificationx(String? payload) async {
  // if (payload != null) {
  //   debugPrint('notification payload: $payload');
  // }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(
  //     builder: (context) => MyHomePage(title: Site.NAME),
  //   ),
  // );
}

void onDidReceiveLocalNotificationx(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: Text(title!),
  //     content: Text(body!),
  //     actions: [
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: const Text('Ok'),
  //         onPressed: () async {
  //           Navigator.of(context, rootNavigator: true).pop();
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyHomePage(title: Site.NAME),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   ),
  // );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // log("Message background");
  // log(message.toString());
  //for ios only
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');
  IOSInitializationSettings initializationSettingsIOS =
      const IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onDidReceiveLocalNotificationx,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotificationx);
  // //request locoal notification permission for ios
  // final bool? result = await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         IOSFlutterLocalNotificationsPlugin>()
  //     ?.requestPermissions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );

  //add notification channel
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'wooapp',
    'App Notification',
    channelDescription: 'Receiving offer notificattions.',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(
    presentAlert:
        false, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    presentBadge:
        false, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    presentSound:
        false, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
    sound: "", // Specifics the file path to play (only from iOS 10 onwards)
    badgeNumber: 0, // The application's icon badge number
    // attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
    // subtitle: String?, //Secondary description  (only from iOS 10 onwards)
    threadIdentifier: "wooapp",
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    iOS: iOSPlatformChannelSpecifics,
    android: androidPlatformChannelSpecifics,
  );

  //since android is receiving message already
  // if (Platform.isIOS) {
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification!.title!,
    message.notification!.body!,
    platformChannelSpecifics,
    payload: 'item-x',
  );
  // }
}

class PushNotificationService {
  // for local notificaton
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails platformChannelSpecifics;
  PushNotificationService(
      {required this.flutterLocalNotificationsPlugin,
      required this.platformChannelSpecifics});

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
    if (Platform.isIOS) {
      //request permission if we're on iOS
      _fcm.requestPermission();
    }

    _fcm.getToken().then((token) async {
      String deviceToken = token.toString();
      // log(deviceToken);
      try {
        var connectivity = await Connectivity().checkConnectivity();
        if (connectivity == ConnectivityResult.none) {
          return;
        }

        UserSession userSession = UserSession();
        await userSession.init();
        //fetch
        String url =
            Site.ADD_DEVICE + userSession.ID + "?token_key=" + Site.TOKEN_KEY;

        dynamic data = {
          "device": deviceToken,
        };

        Response response = await post(url, body: data);

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          //nothing
        } else {
          //nothing
        }
      } finally {
        //nothing
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      // log("Message received");
      // log(message.notification.toString());
      // log(message.notification!.title!);
      // log(message.notification!.body!);
      displayMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // log("Message opended");
      // log(message.toString());
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  displayMessage(RemoteMessage message) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title!,
      message.notification!.body!,
      platformChannelSpecifics,
      payload: 'item-x',
    );
  }
}
