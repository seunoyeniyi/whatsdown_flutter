import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: import_of_legacy_library_into_null_safe
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
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/username_dialog.dart';
import 'package:skyewooapp/ui/validate_phone_dialog.dart';
// import 'package:skyewooapp/screens/signup/components/social_icon.dart';

import '../../../components/already_have_an_account_acheck.dart';
// import 'components/or_divider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  UserSession userSession = UserSession();

  bool useEmail = true; //set to false for using phone
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
    emailController.dispose();
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
                          "Register",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        //using username, email and password
                        Visibility(
                          visible: useEmail,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputForm(
                                controller: usernameController,
                                hintText: "Username",
                                backgroundColor: Colors.transparent,
                                borderWidth: 2,
                                borderColor: Colors.white,
                                textColor: Colors.white,
                                hintTextColor: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              InputForm(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                hintText: "Email",
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
                            "REGISTER",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        AlreadyHaveAnAccountCheck(
                          login: false,
                          press: () {
                            Navigator.pushReplacementNamed(context, "login");
                          },
                        ),

                        const SizedBox(height: 30),
                        //social login
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            const SizedBox(height: 10),
                            Visibility(
                              visible: !useEmail,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
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
                                ],
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
                                padding:
                                    const EdgeInsets.only(top: 13, bottom: 13),
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
                                padding:
                                    const EdgeInsets.only(top: 13, bottom: 13),
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

                        // const OrDivider(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: <Widget>[
                        //     SocalIcon(
                        //       iconSrc: "assets/icons/facebook.svg",
                        //       press: () {},
                        //     ),
                        //     SocalIcon(
                        //       iconSrc: "assets/icons/twitter.svg",
                        //       press: () {},
                        //     ),
                        //     SocalIcon(
                        //       iconSrc: "assets/icons/google-plus.svg",
                        //       press: () {},
                        //     ),
                        //   ],
                        // )
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
              icon: const Text(
                "SKIP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              label: const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.white,
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
        title: "Username!",
        message: "Please enter your username",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }
    if (emailController.text.isEmpty) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Email!",
        message: "Please enter your email",
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text)) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Email!",
        message: "Email is not a valid email address",
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

    //START
    SmartDialog.showLoading(
        clickBgDismissTemp: false, widget: const LoadingBox());

    String url = Site.REGISTER + "?token_key=" + Site.TOKEN_KEY;

    dynamic data = {
      "username": usernameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "token_key": Site.TOKEN_KEY,
    };

    if (userSession.ID != "0") {
      //ID maybe hash code for anonymous user
      data["replace_cart_user"] = userSession.ID;
    }

    Response response = await post(url, body: data);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      if (json.isNotEmpty) {
        if (json.containsKey("code") ||
            json["data"] == null ||
            json["data"] == "null") {
          SmartDialog.dismiss();
          if (json.containsKey("message")) {
            ToastBar.show(context, json["message"], title: "");
          } else {
            ToastBar.show(
                context, "Unable to get you registered at the moment!",
                title: "Access Denied");
          }
        } else {
          Map<String, dynamic> data = json["data"];

          //save user session
          userSession.createLoginSession(
              userID: data["ID"],
              xusername: data["user_login"],
              xemail: data["user_email"],
              logged: true);
          // Toast.show(context, "Registration completed!", title: "Success"); //causes error here, should be used on home page or checkout page
          Toaster.show(message: "Registration completed!");
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
    } else {
      SmartDialog.dismiss();
      Map<String, dynamic> json = jsonDecode(response.body);
      String message = "Something is wrong - Check your input details";
      if (json.isNotEmpty) {
        if (json.containsKey("message")) {
          message = json["message"];
        }
      }
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Error!",
        message: message,
        duration: const Duration(seconds: 3),
      ).show(context);
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
      String email = userData["email"].toString();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const UsernameDialog();
          }).then((value) {
        if (value != null) {
          if (value.toString().isNotEmpty) {
            tryRegisteringByType(
                facebookID, "facebook", value.toString(), email);
          }
        }
      });
    } else {
      //couldn't sign in with facebook
      Toaster.show(message: "Couldn't sign up with Facebook");
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
        String email = user.email;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const UsernameDialog();
            }).then((value) {
          if (value != null) {
            if (value.toString().isNotEmpty) {
              tryRegisteringByType(googleID, "google", value.toString(), email);
            }
          }
        });
      } else {
        //couldn't sign in with google
        Toaster.show(message: "Couldn't sign up with Gooogle");
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
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const UsernameDialog();
              }).then((value) {
            if (value != null) {
              if (value.toString().isNotEmpty) {
                tryRegisteringByType(appleID, "apple", value.toString(),
                    appleID); //appleID == email
              }
            }
          });
        }
      } else {
        //coundn't sign in with apple
        Toaster.show(message: "Couldn't sign up with Apple");
      }
    } finally {
      //finally
    }
  }

  void tryRegisteringByType(
    String registerID,
    String registerType,
    String username,
    String email,
  ) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);

    try {
      //fetch
      String url = Site.REGISTER;
      dynamic data = {
        "username": username,
        "email": email,
        "register_id": registerID,
        "register_type": registerType,
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey("code") || json["data"].toString() == "null") {
          Toaster.show(message: json["message"].toString());
        } else {
          Map<String, dynamic> jsonData = json["data"];
          userSession.createLoginSession(
            userID: jsonData["ID"].toString(),
            xusername: jsonData["user_login"].toString(),
            xemail: jsonData["user_email"].toString(),
            logged: true,
          );
          Toaster.show(message: "Registration Completed");
          userSession.reload();
          SmartDialog.dismiss();

          //check where to go after succesful login
          Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          });
        }
        //end
      } else {
        SmartDialog.dismiss();
        Map<String, dynamic> json = jsonDecode(response.body);
        String message = "Something is wrong - Check your input details";
        if (json.isNotEmpty) {
          if (json.containsKey("message")) {
            message = json["message"];
          }
        }
        Toaster.show(message: message);
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

      if (response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (!json.containsKey("code") && json["data"].toString() != "null") {
          ToastBar.show(
              context, "Phone Number already registered. Login instead");
        } else {
          //do verification
          SmartDialog.dismiss();
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return ValidatePhoneDialog(phone: phoneNumber);
              }).then((value) async {
            if (value.toString() == "validated") {
              await registerPhone();
            } else if (value.toString() == "email") {
              useEmail = true;
            } else {
              Toaster.show(message: "Unable to verify your number.");
            }
          });
        }

        //end
      } else {
        ToastBar.show(context, "Authentication denied");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }

  Future<void> registerPhone() async {
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    try {
      //fetch
      String url = Site.REGISTER_USERNAME;
      dynamic data = {
        "username": phoneNumber,
        "phone": phoneNumber,
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        //end
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey("code") || json["data"].toString() == "null") {
          Toaster.show(message: json["message"].toString());
        } else {
          //success
          Map<String, dynamic> jsonData = json["data"];

          //save user session
          userSession.createLoginSession(
              userID: jsonData["ID"],
              xusername: jsonData["user_login"],
              xemail: jsonData["user_email"],
              logged: true);
          // Toast.show(context, "Registration completed!", title: "Success"); //causes error here, should be used on home page or checkout page
          Toaster.show(message: "Registration completed!");
          userSession.reload();
          SmartDialog.dismiss();

          //check where to go after succesful login
          Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          });
        }
      } else {
        Toaster.show(
            message:
                "Registration denied by the server! - Your phone number may already exists.");
      }
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }
}
