import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/main.dart';
import 'package:skyewooapp/site.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentBrowser extends StatefulWidget {
  const PaymentBrowser({
    Key? key,
    required this.url,
    this.from = "checkout",
  }) : super(key: key);

  final String url;
  final String from;

  @override
  State<PaymentBrowser> createState() => _PaymentBrowserState();
}

class _PaymentBrowserState extends State<PaymentBrowser> {
  WebViewController? _controller;
  // WebViewCookie weCookie = const WebViewCookie(name: "SK_IN_APP", value: "1", domain: "/");

  @override
  void initState() {
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Payment Gateway"),
        ),
        body: WebView(
          backgroundColor: Colors.white,

          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          debuggingEnabled: true,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
            SmartDialog.show(
                clickBgDismissTemp: false,
                widget: const LoadingBox(
                  text: "Please wait...",
                ));
          },
          onPageStarted: (url) {},
          onPageFinished: (url) {
            SmartDialog.dismiss();
          },
          // initialCookies: [weCookie],
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'SkyeFlutterApp',
              onMessageReceived: (JavascriptMessage message) {
                if (message.message == "order_placed") {
                  //show order placed dialog
                  orderPlaced();
                }
              },
            )
          },
        ),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    if (_controller != null) {
      if (await _controller!.canGoBack()) {
        _controller!.goBack();
        return Future.value(false);
      } else {
        return Future.value(true);
      }
    } else {
      return Future.value(true);
    }
  }

  orderPlaced() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.white,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 0,
                    bottom: 70,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/order_placed.png",
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Your order has been placed!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          closeDeal();
                        },
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: AppStyles.flatButtonStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).then((value) {
      closeDeal();
    });
  }

  closeDeal() {
    if (widget.from == "order") {
      Navigator.pop(context); //checkout page will pop it to root and to orders
    } else {
      //pop to root
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              navigateTo: "orders",
              title: Site.NAME, //home page header title - not orders page title
            ),
          ),
          (route) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
