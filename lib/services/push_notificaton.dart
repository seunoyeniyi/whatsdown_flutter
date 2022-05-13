// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/site.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // log("Message background");
  // log(message.toString());
}

class PushNotificationService {
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
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // log("Message opended");
      // log(message.toString());
    });
    //when app is opened and message is also received
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
