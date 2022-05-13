import 'dart:convert';

import 'package:badges/badges.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_character_entities/html_character_entities.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/attributes/attributes_selector.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/components/segment_selector.dart';
import 'package:skyewooapp/handlers/cart.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/handlers/wishlist.dart';
import 'package:skyewooapp/models/attribute.dart';
import 'package:skyewooapp/models/comment.dart';
import 'package:skyewooapp/models/option.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/screens/archive/archive.dart';
import 'package:skyewooapp/screens/product/reviews.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  UserSession userSession = UserSession();

  String cartCount = "0";
  bool showCartCount = false;

  Product product = Product(id: "", name: "");
  bool inWishlist = false;
  bool showSliverTitle = true;

  int _quantity = 1;

  List<Segment> segments = [
    Segment(key: "product", value: const Text("PRODUCT")),
    Segment(key: "reviews", value: const Text("REVIEWS")),
  ];
  String selectedSegment = "product";

  bool isLoading = true;
  bool tryAgain = false;

  //ALL PRODUCT DETAILS
  String description = "";
  String cartProductID = "0";
  String productPrice = "0";
  bool priceAvailable = false;
  bool isVariable = false;
  String categoryName = "Category";
  String categorySlug = "";
  List<Attribute> attributes = [];
  List<Map<String, dynamic>> variations = [];
  bool haveReviews = false;
  double averageRating = 0;
  int reviewsCount = 0;
  List<Comment> comments = [];
  Map<String, String> sizeChartImage = {"type": "none", "path": ""};
  String productUrl = "";
  //END PRODUCT DETAILS

  init() async {
    await userSession.init();
    cartCount = userSession.last_cart_count;
    showCartCount = (int.parse(cartCount) > 0);
    setState(() {});
    fetchDetails();
  }

  @override
  void initState() {
    product = widget.product;
    inWishlist = product.getInWishList == "true";
    cartProductID = product.getID; //parent ID first
    productPrice = product.getPrice;
    isVariable = product.getProductType == "variable";
    priceAvailable = !isVariable;

    if (product.getID.isEmpty || product.getID == "0") {
      Toaster.show(message: "No product selected.");
      Navigator.pop(context);
    }

    init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 400.0,
            stretch: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                showSliverTitle = (constraints.biggest.height < 120);
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  title: Visibility(
                    visible: showSliverTitle,
                    child: Text(
                      product.getName.length > 18
                          ? product.getName.substring(0, 18) + "..."
                          : product.getName,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: (() {
                          if (product.getImage.isNotEmpty &&
                              product.getImage != "false" &&
                              Uri.parse(product.getImage).isAbsolute) {
                            return Container(
                              color: AppColors.f1,
                              child: CachedNetworkImage(
                                memCacheHeight: 480,
                                memCacheWidth: 480,
                                imageUrl: product.getImage,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: AppColors.f1,
                                  highlightColor: Colors.white,
                                  period: const Duration(milliseconds: 500),
                                  child: Container(
                                    color: AppColors.hover,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.f1,
                                  child: const Padding(
                                    padding: EdgeInsets.all(80.0),
                                    child: Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              color: AppColors.f1,
                              child: const Padding(
                                padding: EdgeInsets.all(80.0),
                                child: Icon(Icons.error),
                              ),
                            );
                          }
                        }()),
                      ),

                      //share button
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                Share.share("GET " +
                                    widget.product.getName +
                                    ' - From WhatsDown ' +
                                    productUrl);
                              },
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.share,
                                    size: 18,
                                    color: AppColors.secondary,
                                  ),
                                  SizedBox(width: 3),
                                  Text("Share"),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 5, bottom: 5),
                                primary: Colors.white, // <-- Button color
                                onPrimary: AppColors.black, // <-- Splash color
                                elevation: 5,
                              ),
                            ),
                            //whish list button
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (inWishlist) {
                                    updateWishlist(product.getID, "remove");
                                  } else {
                                    updateWishlist(product.getID, "add");
                                  }
                                  inWishlist =
                                      !inWishlist; //to change icon immediately
                                });
                              },
                              child: SvgPicture.asset(
                                (inWishlist)
                                    ? "assets/icons/icons8_heart.svg"
                                    : "assets/icons/icons8_heart_outline.svg",
                                width: 25,
                                height: 23,
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.only(
                                    left: 6, right: 6, top: 8, bottom: 6),
                                primary: Colors.white, // <-- Button color
                                onPrimary: AppColors.black, // <-- Splash color
                                elevation: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "cart");
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
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.f1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title, and category label
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.getName + " " + product.getID,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivePage(
                                  title: categoryName,
                                  slug: categorySlug,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            color: AppColors.primary,
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Text(
                              HtmlCharacterEntities.decode(categoryName),
                              style:
                                  const TextStyle(color: AppColors.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    child: SegmentSelector(
                      segments: segments,
                      onSelected: (segment) {
                        setState(() {
                          selectedSegment = segment.getKey;
                        });
                      },
                    ),
                  ),
                  //PRODUCT/DETAILS Container
                  Visibility(
                    visible: selectedSegment == "product",
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 0, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //CART OPTION CONTAINER
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //loading
                                Visibility(
                                  visible: isLoading,
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          color: AppColors.hover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //option
                                Visibility(
                                  visible: !isLoading && !tryAgain,
                                  child: Column(
                                    children: [
                                      //price
                                      Visibility(
                                        visible: priceAvailable,
                                        child: Center(
                                          child: Text(
                                            Site.CURRENCY +
                                                Formatter.format(productPrice),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      //attribute
                                      Visibility(
                                        visible: isVariable,
                                        child: AttributesSelector(
                                          attributes: attributes,
                                          variations: variations,
                                          onChanged: (bool found,
                                              String productID, String price) {
                                            setState(() {
                                              priceAvailable = found;
                                              productPrice = price;
                                              if (found) {
                                                cartProductID = productID;
                                              } else {
                                                cartProductID = product.getID;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                //refresh
                                Visibility(
                                  visible: tryAgain,
                                  child: Center(
                                    child: ElevatedButton(
                                      child: const Text("Try Again"),
                                      onPressed: () => fetchDetails(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //DESCRIPTON CONTAINER
                          Visibility(
                            visible: !isLoading &&
                                description.isNotEmpty &&
                                !tryAgain,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(10),
                                    child: Html(
                                      data: description,
                                      defaultTextStyle: const TextStyle(
                                        fontSize: 11,
                                      ),
                                      linkStyle: const TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //REVIEWS Container
                  Visibility(
                    visible: selectedSegment == "reviews",
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //loading
                          Visibility(
                            visible: isLoading,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: AppColors.hover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //Reviews
                          Visibility(
                            visible: !isLoading,
                            child: Reviews(
                              userSession: userSession,
                              productID: product.getID,
                              haveReviews: haveReviews,
                              averageRating: averageRating,
                              reviewsCount: reviewsCount,
                              comments: comments,
                              onReviewUpdated: (int newReviewCount,
                                  bool didHaveReviews,
                                  List<Comment> newComments,
                                  double userRating) {
                                setState(() {
                                  segments[1].setValue = Text("REVIEWS(" +
                                      newReviewCount.toString() +
                                      ")");
                                  haveReviews = didHaveReviews;
                                  reviewsCount = newReviewCount;
                                  averageRating = userRating;
                                });
                              },
                            ),
                          ),
                          //refresh
                          Visibility(
                            visible: tryAgain,
                            child: Center(
                              child: ElevatedButton(
                                child: const Text("Try Again"),
                                onPressed: () => fetchDetails(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //SIZE CHART Container
                  Visibility(
                    visible: selectedSegment == "size_chart",
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //loading
                          Visibility(
                            visible: isLoading,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: AppColors.hover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //size chart image
                          Visibility(
                            visible: !isLoading,
                            child: Container(
                              child: (() {
                                if (sizeChartImage["type"] == "asset") {
                                  return Image.asset(sizeChartImage["path"]!);
                                } else if (sizeChartImage["type"] == "url") {
                                  return CachedNetworkImage(
                                    imageUrl: sizeChartImage["path"]!,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: AppColors.f1,
                                      highlightColor: Colors.white,
                                      period: const Duration(milliseconds: 500),
                                      child: Container(
                                        color: AppColors.hover,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: AppColors.f1,
                                      child: const Padding(
                                        padding: EdgeInsets.all(80.0),
                                        child: Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                      padding: EdgeInsets.all(30),
                                      child: Center(
                                        child: Text("No Size Chart"),
                                      ));
                                }
                              }()),
                            ),
                          ),
                          //refresh
                          Visibility(
                            visible: tryAgain,
                            child: Center(
                              child: ElevatedButton(
                                child: const Text("Try Again"),
                                onPressed: () => fetchDetails(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Image.asset("assets/images/on_every_product.png"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              CartStepper<int>(
                count: _quantity,
                size: 35,
                didChangeCount: (count) {
                  setState(() {
                    if (count > 0) {
                      _quantity = count;
                    } else {
                      _quantity = 1;
                    }
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    addToCart();
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/icons8_shopping_bag.svg",
                    color: AppColors.onPrimary,
                    height: 20,
                    width: 20,
                  ),
                  label: const Text(
                    "ADD TO CART",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 20,
                      right: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateWishlist(String productID, String action) async {
    if (!userSession.logged()) {
      ToastBar.show(context, "You need to login or sign up to add to wishlist!",
          title: "Login Required");
      return;
    }

    Wishlist wishlist = Wishlist(userSession: userSession);
    bool updated = await wishlist.update(userSession.ID, productID, action);

    if (updated) {
      if (action == "remove") {
        inWishlist = false;
        Toaster.show(
            message: "Product removed from wishlist!",
            gravity: ToastGravity.TOP);
      } else {
        inWishlist = true;
        Toaster.show(
            message: "Product added to wishlist!", gravity: ToastGravity.TOP);
      }
    } else {
      Toaster.show(message: "Coudn't update wishlist.");
    }

    if (mounted) {
      setState(() {});
    }
  }

  fetchDetails() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    try {
      setState(() {
        isLoading = true;
        tryAgain = false;
      });
      //fetch
      String url = Site.PRODUCT +
          product.getID +
          "?user_id=" +
          userSession.ID +
          Site.TOKEN_KEY_APPEND;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        //###### PRODUCT URL #######
        productUrl = json["permalink"].toString();
        //###### END PRODUCT URL #######

        //############## DESCRIPTION #####################
        description =
            (json["short_description"] ?? json["description"]).toString();
        if (description == "null") {
          description = "";
        }
        //################ END DESCRIPTION ##################

        //############## CATEGORY NAME #####################
        List<Map<String, dynamic>> categories = List.from(json["categories"]);
        if (categories.isNotEmpty) {
          Map<String, dynamic> category = categories[0];
          categoryName = category["name"].toString();
          categorySlug = category["slug"].toString(); //for onclick of the label

          // SIZE CHART #######################

          if (json.containsKey("sk_size_chart_image")
              ? json["sk_size_chart_image"].toString().isNotEmpty &&
                  json["sk_size_chart_image"].toString().length > 15
              : false) {
            //from the web
            segments.add(
                Segment(key: "size_chart", value: const Text("SIZE CHART")));
            sizeChartImage["type"] = "url";
            sizeChartImage["path"] = json["sk_size_chart_image"].toString();
          } else {
            //from asset or none
            if (category["slug"].toString() == "mens-boxers") {
              segments.add(
                  Segment(key: "size_chart", value: const Text("SIZE CHART")));
              sizeChartImage["type"] = "asset";
              sizeChartImage["path"] =
                  "assets/images/sizingchart_mensboxers.jpg";
            } else if (category["slug"].toString() == "womens-boxers") {
              segments.add(
                  Segment(key: "size_chart", value: const Text("SIZE CHART")));
              sizeChartImage["type"] = "asset";
              sizeChartImage["path"] =
                  "assets/images/sizingchart_womensboxers.jpg";
            } else if (category["slug"].toString() == "t-shirts") {
              segments.add(
                  Segment(key: "size_chart", value: const Text("SIZE CHART")));
              sizeChartImage["type"] = "asset";
              sizeChartImage["path"] =
                  "assets/images/sizingchart_unisex_tshirt.jpg";
            } else {
              sizeChartImage["type"] = "none";
              sizeChartImage["path"] = "";
            }
          }

          // END SIZE CHART #######################

        }
        //############## END CATEGRY NAME #####################

        //############### ATTRIBUTES and VARIATIONS ####################
        if (json["type"].toString() == "variable" ||
            json["product_type"].toString() == "variable") {
          variations = List.from(json["variations"]);
          List<Map<String, dynamic>> attrs = List.from(json["attributes"]);

          //for each attributes
          for (var attribute in attrs) {
            //get each attribute options
            List<Map<String, dynamic>> jsonOptions =
                List.from(attribute["options"]);
            List<Option> option = [];
            //for each of the options
            for (var opt in jsonOptions) {
              option.add(Option(
                name: opt["name"].toString(),
                value: opt["value"].toString(),
              ));
            }
            //add the options, name, and label to the global attributes;
            attributes.add(Attribute(
              name: attribute["name"].toString(),
              label: attribute["label"].toString(),
              options: option,
            ));
          }
        }
        //##################### END ATTRIBUTES and VARIATIONS #######################

        //################## RATING AND REVIEWS ###################
        List<Map<String, dynamic>> jsonComments = List.from(json["comments"]);
        if (jsonComments.isNotEmpty) {
          haveReviews = true;
          averageRating = double.parse(json["average_rating"].toString());
          reviewsCount = int.parse(json["review_count"].toString());
          // segments["reviews"] = Text("REVIEWS(" + reviewsCount.toString() + ")");
          segments[1].setValue =
              Text("REVIEWS(" + reviewsCount.toString() + ")");
        }

        //issue not zero rating with only one user rating
        if (jsonComments.isNotEmpty &&
            json["average_rating"].toString() == "0" &&
            json["review_count"].toString() == "1") {
          averageRating = double.parse(jsonComments[0]["rating"].toString());
        }

        for (var comment in jsonComments) {
          comments.add(Comment(
            username: comment["comment_author"].toString(),
            comment: comment["comment_content"].toString(),
            rating: comment["rating"].toString(),
            userImage: comment["user_image"].toString(),
          ));
        }
        //################ END RATING AND REVIEWS #######################

      } else {
        Toaster.show(message: "Unable to get product.");
        tryAgain = true;
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  addToCart() async {
    Cart cart = Cart(userSession: userSession);
    if (priceAvailable && cartProductID != "0") {
      SmartDialog.showLoading(
          clickBgDismissTemp: false,
          widget: const LoadingBox(
            text: "Adding to cart...",
          ));

      Map<String, dynamic> result =
          await cart.addToCart(productID: cartProductID, quantity: _quantity);

      if (result["status"] == "success") {
        setState(() {
          cartCount = result["contents_count"].toString();
          showCartCount = int.parse(cartCount) > 0;
        });
        Toaster.showIcon(
          message: "Product added to cart",
          icon: Icons.check,
          context: context,
          gravity: ToastGravity.TOP,
          duration: 3,
        );
      } else {
        ToastBar.show(context, result["message"].toString());
      }
    } else {
      Toaster.show(
        message: "Please select product option.",
        gravity: ToastGravity.CENTER,
      );
    }
    SmartDialog.dismiss();
  }
}
