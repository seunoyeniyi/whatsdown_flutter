import 'package:flutter/material.dart';
import 'package:skyewooapp/ui/app_bar.dart';
import 'package:skyewooapp/ui/shop/shop.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({
    Key? key,
    this.orderBy = "default",
  }) : super(key: key);

  final String orderBy;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  AppAppBarController appBarController = AppAppBarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        titleType: "logo",
      ),
      body: ShopBody(
        appBarController: appBarController,
        orderBy: widget.orderBy,
      ),
    );
  }
}
