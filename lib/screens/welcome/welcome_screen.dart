import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/user_session.dart';

import '../../../components/rounded_button.dart';
import '../../app_colors.dart';
import 'background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserSession userSession = UserSession();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await userSession.init();
    checkLogin();
  }

  checkLogin() async {
    await userSession.reload();
    if (userSession.logged()) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width / 2) + 20,
            height: MediaQuery.of(context).size.height - 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/title-logo.png",
                  height: 50,
                ),
                const SizedBox(height: 40),
                const Text(
                  "The Right Address For Shopping Anyday",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Create an account or login!",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Text(
                  "We promise it's worth it.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 60),
                TextButton(
                  style: AppStyles.flatButtonStyle(),
                  onPressed: () {
                    Navigator.pushNamed(context, "register").then((value) {
                      if (value.toString() == "skip") {
                        Navigator.pop(context);
                      } else {
                        checkLogin();
                        setState(() {});
                      }
                    });
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: AppStyles.flatButtonStyle(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "login").then((value) {
                      if (value.toString() == "skip") {
                        Navigator.pop(context);
                      } else {
                        checkLogin();
                        setState(() {});
                      }
                    });
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
