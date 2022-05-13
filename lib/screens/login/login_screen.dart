// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/screens/login/background.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:skyewooapp/site.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:skyewooapp/ui/validate_phone_dialog.dart';

import '../../../components/already_have_an_account_acheck.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  UserSession userSession = UserSession();

  bool useEmail = false;
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await userSession.init();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Background(
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
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        //use email/username and passwrod
                        Visibility(
                          visible: useEmail,
                          child: Column(
                            children: [
                              InputForm(
                                controller: usernameController,
                                hintText: "Username or email",
                                backgroundColor: Colors.transparent,
                                borderWidth: 2,
                                borderColor: Colors.white,
                                textColor: Colors.white,
                                hintTextColor: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              InputForm(
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                controller: passwordController,
                                hintText: "Password",
                                backgroundColor: Colors.transparent,
                                borderWidth: 2,
                                borderColor: Colors.white,
                                textColor: Colors.white,
                                hintTextColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        //use phone
                        Visibility(
                          visible: !useEmail,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: IntlPhoneField(
                              controller: phoneController,
                              dropdownIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              disableLengthCheck: true,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              dropdownTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                                labelStyle: TextStyle(color: Colors.white),
                                hintText: 'Phone Number',
                              ),
                              initialCountryCode: 'IN',
                              onChanged: (phone) {
                                String code =
                                    phone.countryCode.replaceFirst("+", "");
                                String number = phone.number;

                                if (number.startsWith("0")) {
                                  number = number.replaceFirst("0", "");
                                }

                                //phone number to ue for signing
                                phoneNumber = code + number;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        TextButton(
                          style: AppStyles.flatButtonStyle(),
                          onPressed: _submit,
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AlreadyHaveAnAccountCheck(
                          press: () {
                            Navigator.pushReplacementNamed(context, "register");
                          },
                        ),
                        //social login
                        Visibility(
                          visible: !useEmail,
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              const Center(
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                style: AppStyles.flatButtonStyle(
                                  padding: const EdgeInsets.only(
                                      top: 13, bottom: 13),
                                  backgroundColor: AppColors.secondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    useEmail = true;
                                  });
                                },
                                child: const Text(
                                  "Use Username/Email",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.facebook,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                style: AppStyles.flatButtonStyle(
                                  padding: const EdgeInsets.only(
                                      top: 13, bottom: 13),
                                  backgroundColor: const Color(0XFF1878F3),
                                ),
                                onPressed: _facebookTapped,
                                label: const Text(
                                  "Login with Facebook",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                icon: SvgPicture.asset(
                                  "assets/icons/google-plus.svg",
                                  color: Colors.red,
                                  height: 18,
                                  width: 18,
                                ),
                                style: AppStyles.flatButtonStyle(
                                  padding: const EdgeInsets.only(
                                      top: 13, bottom: 13),
                                  backgroundColor: AppColors.white,
                                ),
                                onPressed: _googleTapped,
                                label: const Text(
                                  "Login with Google",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 10),
                              (() {
                                if (Platform.isIOS) {
                                  return TextButton.icon(
                                    icon: SvgPicture.asset(
                                      "assets/icons/icons8_apple_logo.svg",
                                      color: Colors.white,
                                      height: 18,
                                      width: 18,
                                    ),
                                    style: AppStyles.flatButtonStyle(
                                      padding: const EdgeInsets.only(
                                          top: 13, bottom: 13),
                                      backgroundColor: AppColors.black,
                                    ),
                                    onPressed: _appleTapped,
                                    label: const Text(
                                      "Login with Apple",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //skip
          Positioned(
            right: 14,
            top: 50,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_right, color: Colors.white),
              label: const Text(
                "SKIP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "skip");
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    FocusScope.of(context).unfocus();
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }

    if (!useEmail) {
      checkPhoneExists();
      return;
    }

    if (usernameController.text.isEmpty) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Username or Email!",
        message: "Please enter your username or email",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    if (passwordController.text.isEmpty) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Password!",
        message: "Please enter your password",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    SmartDialog.showLoading(
        clickBgDismissTemp: false, widget: const LoadingBox());

    String url = Site.LOGIN + "?token_key=" + Site.TOKEN_KEY;

    dynamic data = {
      "username": usernameController.text,
      "password": passwordController.text,
      "token_key": Site.TOKEN_KEY,
    };

    if (userSession.ID != "0") {
      //ID maybe hash code for anonymous user
      data["replace_cart_user"] = userSession.ID;
    }

    Response response = await post(url, body: data);

    if (response.statusCode == 200) {
      parseBody(response.body);
    } else {
      SmartDialog.dismiss();
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Error!",
        message: "Access denied, please re-check your details.",
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void parseBody(String body) {
    Map<String, dynamic> json = jsonDecode(body);
    if (json.isNotEmpty) {
      if (json.containsKey("code") ||
          json["data"] == null ||
          json["data"] == "null") {
        SmartDialog.dismiss();
        ToastBar.show(context, "Incorrect login details!",
            title: "Access Denied");
      } else {
        Map<String, dynamic> data = json["data"];

        //save user session
        userSession.createLoginSession(
            userID: data["ID"],
            xusername: data["user_login"],
            xemail: data["user_email"],
            logged: true);
        // Toast.show(context, "Welcome Back!", title: "Success"); //causes error here, should be used on home page or checkout page
        Toaster.show(message: "Welcome Back!");
        userSession.reload();
        SmartDialog.dismiss();

        //check where to go after succesful login
        Future.delayed(Duration.zero, () {
          Navigator.pop(context);
        });
      }
    } else {
      SmartDialog.dismiss();
      ToastBar.show(context, "Coudn't get any result!");
    }
  }

  _facebookTapped() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['id', 'public_profile', 'email'],
    ); // by default we request the email and the public profile

    // or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      // final AccessToken accessToken = result.accessToken!;
      //user data
      final userData = await FacebookAuth.instance.getUserData();
      String facebookID = userData["id"].toString();
      fetchLoginByType(facebookID, "facebook");
    } else {
      //couldn't sign in with facebook
      Toaster.show(message: "Couldn't login with Facebook");
      log(result.status.toString());
      log(result.message.toString());
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  _googleTapped() async {
    try {
      var user = await _googleSignIn.signIn();
      if (user != null) {
        //id
        String googleID = user.id;
        fetchLoginByType(googleID, "google");
      } else {
        //couldn't sign in with google
        Toaster.show(message: "Couldn't login with Gooogle");
      }
    } catch (error) {
      log(error.toString());
    } finally {
      _googleSignIn.disconnect();
    }
  }

  _appleTapped() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.email != null) {
        if (credential.email!.isNotEmpty) {
          String appleID =
              credential.email.toString(); //let  use email for the user id
          fetchLoginByType(appleID, "apple");
        }
      } else {
        //coundn't sign in with apple
        Toaster.show(message: "Couldn't login with Apple");
      }
    } finally {
      //finally
    }
  }

  void fetchLoginByType(String loginID, String loginType) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    try {
      //fetch
      String url = Site.LOGIN;
      dynamic data = {
        "login_id": loginID,
        "login_type": loginType,
        "token_key": Site.TOKEN_KEY,
      };
      if (userSession.ID != "0") {
        data["replace_cart_user"] = userSession.ID;
      }

      Response response = await post(url, body: data);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        parseBody(response.body);
      } else {
        ToastBar.show(
          context,
          "Error occured. Please try again or contact us.",
        );
      }
    } finally {
      SmartDialog.dismiss();
    }
  }

  void checkPhoneExists() async {
    if (phoneController.text.isEmpty) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Phone Number!",
        message: "Please enter your phone number or tap use username/email",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    try {
      //fetch
      String url = Site.AUTHENTICATE_USERNAME;

      dynamic data = {
        "username": phoneNumber,
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey("code") || json["data"].toString() == "null") {
          ToastBar.show(context, "Phone Number not found!");
        } else {
          Map<String, dynamic> jsonData = json["data"];
          SmartDialog.dismiss();
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return ValidatePhoneDialog(phone: phoneNumber);
              }).then((value) {
            if (value.toString() == "validated") {
              userSession.createLoginSession(
                userID: jsonData["ID"].toString(),
                xusername: jsonData["user_login"].toString(),
                xemail: jsonData["user_email"].toString(),
                logged: true,
              );
              Toaster.show(message: "Welcome Back!");
              userSession.reload();

              Future.delayed(Duration.zero, () {
                Navigator.pop(context);
              });
            } else if (value.toString() == "email") {
              useEmail = true;
            } else {
              Toaster.show(message: "Unable to verify your number.");
            }
          });
        }

        //end
      } else {
        ToastBar.show(
            context, "Authentication denied OR Phone Number not found!");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }
}
