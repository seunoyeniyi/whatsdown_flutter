import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppBrowser extends StatefulWidget {
  const AppBrowser({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  State<AppBrowser> createState() => _AppBrowserState();
}

class _AppBrowserState extends State<AppBrowser> {
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
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: WebView(
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

  @override
  void dispose() {
    super.dispose();
  }
}
