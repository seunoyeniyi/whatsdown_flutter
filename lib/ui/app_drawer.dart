import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/home.dart';
import 'package:skyewooapp/screens/archive/archive.dart';
import 'package:skyewooapp/screens/browser.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/tracking_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  UserSession userSession = UserSession();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await userSession.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Drawer(
        child: ListTileTheme(
          textColor: Colors.black,
          iconColor: Colors.black,
          horizontalTitleGap: 2,
          contentPadding: const EdgeInsets.only(left: 30),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              //DRAWER HEADER
              SizedBox(
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Image.asset(
                            "assets/images/boy_man_avatar.png",
                            height: 70,
                            width: 70,
                            cacheHeight: 150,
                            cacheWidth: 150,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                      (userSession.logged())
                                          ? userSession.username
                                          : "Hi!",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                                margin: const EdgeInsets.only(bottom: 5),
                              ),
                              SizedBox(
                                height: 25,
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                      const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 0,
                                        bottom: 0,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: loginTapped,
                                  child: Text(
                                    (userSession.logged())
                                        ? "Account"
                                        : "Log In",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //DRAWER LISTS
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_home.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  MyHomePage.changeBody(context, 0);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_shopping_bag.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Shop',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  MyHomePage.changeBody(context, 1);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_fantasy_1.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Categories',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "categories");
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_heart_outline.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Wishlist',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  if (userSession.logged()) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "wishlist");
                  } else {
                    Toaster.show(
                        message: "Please Login or Register first.",
                        gravity: ToastGravity.TOP);
                  }
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_basket.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Orders',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  if (userSession.logged()) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "orders");
                  } else {
                    Toaster.show(
                      message: "Please Login or Register first.",
                      gravity: ToastGravity.TOP,
                    );
                  }
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_rss.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Blog',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "blog?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "Blog",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_loyalty_card.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Sales',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivePage(
                        title: "Sales",
                        slug: "sale",
                        subTitle: "With Discount",
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/icons/icons8_track_order.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text(
                  'Track Order',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showTrackingDialog();
                },
              ),

              const SizedBox(height: 30),

              ListTile(
                title: const Text(
                  'Support',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  String url =
                      "whatsapp://send?phone=919076012700?text=Hi, *WhatsDown Support Team*";
                  final Uri uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Toaster.show(message: "No whatsapp installed");
                  }
                },
              ),
              ListTile(
                title: const Text(
                  'Shipping',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "shipping?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "Shipping",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'Returns',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "returns?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "Returns",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'FAQs',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "faqs?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "FAQs",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'Contact',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "contact-us?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "Contact",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'About',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String url = Site.ADDRESS + "about-us?in_sk_app=1";
                  url +=
                      "&hide_elements=div*topbar.topbar, div.topbar, div.joinchat__button, div.joinchat, div*notificationx-frontend-root";
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBrowser(
                        title: "About",
                        url: url,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(
                  (userSession.logged()) ? "Log Out" : "Log In",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: logoutTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }

  loginTapped() {
    Navigator.pop(context);
    if (userSession.logged()) {
      Navigator.pushNamed(context, "account");
    } else {
      Navigator.pushNamed(context, "welcome");
    }
  }

  logoutTapped() {
    Navigator.pop(context);
    if (userSession.logged()) {
      userSession.logout();
      MyHomePage.restartApp(context);
    } else {
      Navigator.pushNamed(context, "welcome");
    }
  }

  showTrackingDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const TrackingDialog();
        });
  }
}
