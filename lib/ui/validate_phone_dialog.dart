import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/screens/login/background.dart';

class ValidatePhoneDialog extends StatefulWidget {
  const ValidatePhoneDialog({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final String phone;

  @override
  State<ValidatePhoneDialog> createState() => _ValidatePhoneDialogState();
}

class _ValidatePhoneDialogState extends State<ValidatePhoneDialog> {
  TextEditingController otpController = TextEditingController();

  String codeSent = "";
  bool sent = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // Add Your Code here.
        sendSMS();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              height: size.height - 10,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "Verify Phone",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 38,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        sent
                            ? "W've sent verification code to your number +" +
                                widget.phone
                            : "We couldn't send SMS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sent ? Colors.white : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputForm(
                      keyboardType: TextInputType.number,
                      controller: otpController,
                      hintText: "Enter Code",
                      backgroundColor: Colors.transparent,
                      borderWidth: 2,
                      borderColor: Colors.white,
                      textColor: Colors.white,
                      hintTextColor: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      style: AppStyles.flatButtonStyle(),
                      onPressed: _validate,
                      child: const Text(
                        "VALIDATE",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      style: AppStyles.flatButtonStyle(
                        padding: const EdgeInsets.only(top: 13, bottom: 13),
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        Navigator.pop(context, "email");
                      },
                      child: const Text(
                        "Use Username/Email",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void sendSMS() async {
    sent = false;
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    try {
      //fetch
      var rng = Random();
      var code = rng.nextInt(9000) + 1000;
      codeSent = code.toString();

      String to = widget.phone;

      String message = "WhatsDown - Verification code: " +
          codeSent +
          ". To verify your account";

      String token =
          "OeeRY6WXQ7CtdJMliB4LCVphUvNbGieGznVcnbWKMLBlVj1sJ9FeJTAE0l1ypy28";

      message = message.replaceAll(" ", "+");

      String url = "https://gatewayapi.com/rest/mtsms?token=" +
          token +
          "&message=" +
          message +
          "&recipients.0.msisdn=" +
          to;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey("message") && json.containsKey("code")) {
          sent = false;
          Toaster.show(message: json["message"].toString());
        } else {
          sent = true;
        }
      } else {
        sent = false;
        Toaster.show(message: "Unable to send SMS. Please use email");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }

  _validate() {
    if (codeSent.isNotEmpty && codeSent == otpController.text) {
      Navigator.pop(context, "validated");
    } else {
      Toaster.show(message: "Incorrect verificaton code");
    }
  }
}
