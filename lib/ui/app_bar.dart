// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/cart.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/site_info.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/ui/search/search_delegate.dart';

class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppBar({
    Key? key,
    this.preferredSize = const Size.fromHeight(56.0),
    required this.controller,
    this.appBarType = "main",
    this.title = "",
    this.titleType = "logo",
    this.hasCart = true,
    this.hasSearch = true,
    this.hasWishlist = true,
    this.elevation = 0,
  }) : super(key: key);

  final AppAppBarController controller;
  final String appBarType;
  final String title;
  final String titleType;
  final bool hasWishlist;
  final bool hasCart;
  final bool hasSearch;
  final double elevation;

  @override
  final Size preferredSize;

  @override
  State<AppAppBar> createState() => _AppAppBarState();
}

class _AppAppBarState extends State<AppAppBar> {
  UserSession userSession = UserSession();
  SiteInfo siteInfo = SiteInfo();
  String cartCount = "0";
  bool showCartCount = false;
  bool showWishlistBadge = false;
  String logoURL = "";

  init() async {
    refreshAll();
  }

  refreshAll() async {
    await userSession.init();
    await siteInfo.init();
    cartCount = userSession.last_cart_count;
    showCartCount = (int.parse(cartCount) > 0);
    logoURL = await siteInfo.getMainLogo();

    setState(() {});
    if (userSession.logged()) {
      fetchCart();
      showWishlistBadge = (int.parse(userSession.last_wishlist_count) > 0);
    }
  }

  @override
  void initState() {
    //apply controllers
    widget.controller.updateWishlistBadge = updateWishlistBadge;
    widget.controller.updateCartCount = updateCartCount;
    widget.controller.displaySearch = displaySearch;
    widget.controller.refreshAll = refreshAll;
    widget.controller.updateLogo = updateLogo;

    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: widget.elevation,
      title: (() {
        if (widget.titleType == "logo") {
          if (logoURL.length > 10 && Uri.parse(logoURL).isAbsolute) {
            return CachedNetworkImage(
              imageUrl: logoURL,
              placeholder: (context, url) => Image.asset(
                'assets/images/title-logo.png',
                fit: BoxFit.contain,
                height: 30,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/title-logo.png',
                fit: BoxFit.contain,
                height: 30,
              ),
            );
          } else {
            return Image.asset(
              'assets/images/title-logo.png',
              fit: BoxFit.contain,
              height: 30,
            );
          }
        } else {
          return Text(widget.title);
        }
      }()),
      leading: Builder(
        builder: (context) {
          return IconButton(
            onPressed: () {
              if (widget.appBarType == "main") {
                if (Scaffold.of(context).hasDrawer) {
                  Scaffold.of(context).openDrawer();
                }
              } else {
                Navigator.pop(context);
              }
            },
            icon: (() {
              if (widget.appBarType == "main") {
                return SvgPicture.asset(
                  "assets/icons/icons8_align_left.svg",
                  height: 30,
                  width: 30,
                );
              } else {
                return const Icon(Icons.arrow_back);
              }
            }()),
          );
        },
      ),
      actions: <Widget>[
        //heart wishlist
        (() {
          if (widget.hasWishlist) {
            return IconButton(
              onPressed: () {
                if (userSession.logged()) {
                  if (AppRoute.getName(context) != "wishlist") {
                    Navigator.pushNamed(context, "wishlist").then((value) {
                      refreshAll();
                    });
                  }
                } else {
                  Toaster.show(message: "Please login or register first");
                }
              },
              icon: Badge(
                position: BadgePosition.topEnd(top: -8, end: -4),
                showBadge: showWishlistBadge,
                padding: const EdgeInsets.all(7),
                badgeContent: const Text(
                  "",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                badgeColor: Colors.red,
                child: SvgPicture.asset(
                  (showWishlistBadge)
                      ? "assets/icons/icons8_heart.svg"
                      : "assets/icons/icons8_heart_outline.svg",
                  height: 25,
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }()),
        //bag shopping cart
        (() {
          if (widget.hasCart) {
            return IconButton(
              onPressed: () {
                if (AppRoute.getName(context) != "cart") {
                  Navigator.pushNamed(context, "cart").then((value) {
                    refreshAll();
                  });
                }
              },
              icon: Badge(
                position: BadgePosition.topEnd(top: -8, end: -4),
                showBadge: showCartCount,
                padding: const EdgeInsets.all(5),
                badgeContent: Text(
                  cartCount,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                badgeColor: AppColors.primary,
                child: SvgPicture.asset(
                  "assets/icons/icons8_shopping_bag.svg",
                  height: 25,
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }()),
        //search
        (() {
          if (widget.hasSearch) {
            return IconButton(
              onPressed: () {
                showSearch(context: context, delegate: AppBarSearchDelegate());
              },
              icon: SvgPicture.asset(
                "assets/icons/icons8_search.svg",
                height: 25,
              ),
            );
          } else {
            return const SizedBox();
          }
        }()),
      ],
    );
  }

  void displaySearch() {
    showSearch(context: context, delegate: AppBarSearchDelegate())
        .then((value) {
      refreshAll();
    });
  }

  fetchCart() async {
    Cart cart = Cart(userSession: userSession);
    cartCount = await cart.fetchCount();
    if (int.parse(cartCount) > 0) {
      showCartCount = true;
      userSession.update_last_cart_count(cartCount);
    } else {
      showCartCount = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void updateCartCount(String count) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        cartCount = count;
        showCartCount = (int.parse(cartCount) > 0);
      });
    });
  }

  void updateWishlistBadge(String count) {
    if (mounted) {
      setState(() {
        showWishlistBadge = (int.parse(count) > 0);
      });
    }
  }

  void updateLogo(String url) {
    if (mounted) {
      setState(() {
        logoURL = url;
      });
    }
  }
}

class AppAppBarController {
  void Function(String)? updateWishlistBadge;
  void Function(String)? updateCartCount;
  void Function()? displaySearch;
  void Function()? refreshAll;
  void Function(String url)? updateLogo;
}
