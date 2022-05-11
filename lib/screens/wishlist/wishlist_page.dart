import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyewooapp/components/product_card.dart';
import 'package:skyewooapp/components/shimmer_product_card.dart';
import 'package:skyewooapp/components/shimmer_shop.dart';
import 'package:skyewooapp/controllers/products_controller.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/screens/product/product_page.dart';
import 'package:skyewooapp/ui/app_bar.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  AppAppBarController appBarController = AppAppBarController();

  ProductsController productsController = Get.put(ProductsController());

  init() async {
    Get.reset();
    productsController = Get.put(ProductsController(forWishlist: true));
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 180) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        title: "Wishlist",
        titleType: "title",
        hasSearch: false,
        elevation: 0.5,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollDirection: Axis.vertical,
          child: Obx(() {
            //message report
            for (var message in productsController.messages) {
              Toaster.show(message: message);
            }
            //end message report

            //update wishlist badge of the appbar
            if (appBarController.refreshAll != null) {
              appBarController.refreshAll!();
            }

            if (productsController.isLoading.value &&
                productsController.products.isEmpty) {
              return ShopShimmer(
                itemWidth: itemWidth,
                itemHeight: itemHeight,
              );
            } else {
              return productsLayout(itemWidth, itemHeight);
            }
          }),
        ),
      ),
    );
  }

  Widget productsLayout(double itemWidth, double itemHeight) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (itemWidth / itemHeight),
            children:
                List.generate(productsController.products.length, (index) {
              double regularPrice = (isNumeric(
                      productsController.products[index].getRegularPrice))
                  ? double.parse(
                      productsController.products[index].getRegularPrice)
                  : 0;
              double price =
                  double.parse(productsController.products[index].getPrice);

              double discount = regularPrice - price;

              return ProductCard(
                userSession: productsController.userSession.value,
                productID: productsController.products[index].getID,
                productTitle: productsController.products[index].getName,
                productType: productsController.products[index].getProductType,
                image: productsController.products[index].getImage,
                regularPrice:
                    productsController.products[index].getRegularPrice,
                price: productsController.products[index].getPrice,
                inWishlist: (productsController.products[index].getInWishList ==
                    "true"),
                discountValue: (discount > 0) ? discount.toString() : "0",
                onPressed: ({bool? inWishlist}) {
                  //product
                  Product product = productsController.products[index];
                  //if wishlist was updated
                  if (inWishlist != null) {
                    product.setInWishList = inWishlist.toString();
                  }
                  //push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(product: product),
                    ),
                  ).then((dynamic result) {
                    //refresh necessary UIs
                    if (appBarController.refreshAll != null) {
                      appBarController.refreshAll!();
                    }
                  });
                },
                onWishlistUpdated: () {
                  if (appBarController.refreshAll != null) {
                    appBarController.refreshAll!();
                  }
                },
              );
            }),
          ),
          //LOADING MORE DATA PLACE HOLDER
          (productsController.isLoading.value &&
                  productsController.products.isNotEmpty)
              ? loadingMoreShimmerPlaceholder(itemWidth, itemHeight)
              : const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget loadingMoreShimmerPlaceholder(double itemWidth, double itemHeight) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (itemWidth / itemHeight),
      children: List.generate(4, (index) {
        return const ShimmerProductCard();
      }),
    );
  }
}
