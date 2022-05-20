import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyewooapp/components/product_card.dart';
import 'package:skyewooapp/components/shimmer_product_card.dart';
import 'package:skyewooapp/components/shimmer_shop.dart';
import 'package:skyewooapp/controllers/products_controller.dart';
import 'package:skyewooapp/controllers/search_suggestion_controller.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/category.dart';
import 'package:skyewooapp/models/option.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/models/tag.dart';
import 'package:skyewooapp/screens/product/product_page.dart';
import 'package:skyewooapp/ui/filter_dialog.dart';
import 'package:skyewooapp/ui/search/suggestion_card.dart';
import 'package:skyewooapp/ui/search/suggestion_shimmer.dart';

class AppBarSearchDelegate extends SearchDelegate {
  ProductsController productsController =
      Get.put(ProductsController(initialize: false, isLoading: false));
  SuggestionController suggestionController = Get.put(SuggestionController());

  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 5.0);

  //FILTER LISTs
  List<Category>? categories;
  List<Tag>? tags;
  List<Option>? colors;
  RangeValues? priceRange;
  //INDEX
  int? selectedCatIndex;
  int? selectedTagIndex;
  int? selectedColorIndex;

  init() async {
    Get.reset();
    productsController =
        Get.put(ProductsController(initialize: false, isLoading: false));
    _scrollController = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  AppBarSearchDelegate() {
    init();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null); //close searchbar
          } else {
            query = "";
          }
        },
        icon: const Icon(Icons.clear),
      ),
      IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return FilterDialog(
                  categories: categories,
                  tags: tags,
                  colors: colors,
                  priceRange: priceRange,
                  selectedCatIndex: selectedCatIndex,
                  selectedColorIndex: selectedColorIndex,
                  selectedTagIndex: selectedTagIndex,
                  selected_category: productsController.selected_category,
                  selected_color: productsController.selected_color,
                  selected_tag: productsController.selected_tag,
                );
              }).then(filterResult);
        },
        icon: const Icon(Icons.tune),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null); //close searchbar
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length > 3) {
      suggestionController.search.value = query;
      suggestionController.fetchProducts();
    }
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Obx(() {
            if (suggestionController.isLoading.value) {
              return const SuggestionShimmer();
            } else {
              return Column(
                children: List.generate(suggestionController.products.length,
                    (index) {
                  return SuggestionCard(
                    product: suggestionController.products[index],
                    onSelected: (Product product) {
                      if (product.getID != "0" && product.getImage.isNotEmpty) {
                        //push
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductPage(product: product),
                          ),
                        );
                      } else {
                        //search
                        showResults(context);
                      }
                    },
                  );
                }),
              );
            }
          }),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 140) / 2;
    final double itemWidth = size.width / 2;

    if (!productsController.isLoading.value) {
      productsController.search.value = query;
      productsController.fetchProducts(append: false);
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: Obx(() {
          //message report
          for (var message in productsController.messages) {
            Toaster.show(message: message);
          }
          //end message report

          if (productsController.isLoading.value &&
              productsController.products.isEmpty) {
            return ShopShimmer(
              itemWidth: itemWidth,
              itemHeight: itemHeight,
            );
          } else {
            return productsLayout(context, itemWidth, itemHeight);
          }
        }),
      ),
    );
  }

  Widget productsLayout(
      BuildContext context, double itemWidth, double itemHeight) {
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
                    // if (appBarController.refreshAll != null) {
                    //   appBarController.refreshAll!();
                    // }
                  });
                },
                onWishlistUpdated: () {
                  // if (appBarController.refreshAll != null) {
                  //   appBarController.refreshAll!();
                  // }
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

  _scrollListener() {
    if (_scrollController.offset >=
            (_scrollController.position.maxScrollExtent - 500) &&
        !_scrollController.position.outOfRange &&
        !productsController.isLoading.value &&
        !productsController.gotToEnd.value &&
        productsController.products.length > 10) {
      if (!productsController.isLoading.value) {
        productsController.currentPaged = productsController.currentPaged + 1;
        productsController.paged = productsController.currentPaged.toString();
        productsController.fetchProducts();
      }
    }
  }

  filterResult(dynamic result) {
    if (result != null) {
      if (result is Map) {
        categories = result["categories"];
        tags = result["tags"];
        colors = result["colors"];
        priceRange = result["price_range"];

        selectedCatIndex = result["selected_cat_index"];
        selectedTagIndex = result["selected_tag_index"];
        selectedColorIndex = result["selected_color_index"];

        productsController.selected_category = result["selected_category"];
        productsController.selected_tag = result["selected_tag"];
        productsController.selected_color = result["selected_color"];
        productsController.priceRange = result["price_range"];
        productsController.fetchProducts(append: false);
      }
    }
  }
}
