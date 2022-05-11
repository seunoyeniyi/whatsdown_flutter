import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/product_card.dart';
import 'package:skyewooapp/components/shimmer_product_card.dart';
import 'package:skyewooapp/components/shimmer_shop.dart';
import 'package:skyewooapp/controllers/products_controller.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/category.dart';
import 'package:skyewooapp/models/option.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/models/tag.dart';
import 'package:skyewooapp/screens/product/product_page.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/app_bar.dart';
import 'package:skyewooapp/ui/filter_dialog.dart';
import 'package:skyewooapp/ui/search/search_delegate.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({
    Key? key,
    required this.title,
    required this.slug,
    this.subTitle = "",
  }) : super(key: key);

  final String title;
  final String slug;
  final String subTitle;

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  AppAppBarController appBarController = AppAppBarController();

  ProductsController productsController = Get.put(ProductsController());

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
        Get.put(ProductsController(selected_category: widget.slug));
    _scrollController = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
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
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        titleType: "logo",
        title: widget.title,
        hasSearch: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Material(
              //HEADER FILTER
              elevation: 1,
              child: Container(
                padding: const EdgeInsets.all(0),
                width: double.infinity,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.f1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //CATEGORY TITLE
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title.isNotEmpty
                                  ? widget.title.replaceAll("\\", "")
                                  : Site.NAME,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            (() {
                              if (widget.subTitle.isNotEmpty) {
                                return Text(
                                  widget.subTitle.replaceAll("\\", ""),
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            }()),
                          ],
                        ),
                      ),
                    ),

                    // SEARCH ICON BUTTON
                    SizedBox(
                      width: 50,
                      child: Material(
                        color: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            showSearch(
                              context: context,
                              delegate: AppBarSearchDelegate(),
                            ).then((value) {
                              if (appBarController.refreshAll != null) {
                                appBarController.refreshAll!();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    // FILTER ICON BUTTON
                    SizedBox(
                      width: 50,
                      child: Material(
                        color: Colors.white,
                        child: IconButton(
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
                                      selected_category:
                                          productsController.selected_category,
                                      selected_color:
                                          productsController.selected_color,
                                      selected_tag:
                                          productsController.selected_tag,
                                    );
                                  }).then(filterResult);
                            },
                            icon: const Icon(
                              Icons.tune,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
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
                  productsController.messages.clear();
                  //end message report

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
          ],
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
