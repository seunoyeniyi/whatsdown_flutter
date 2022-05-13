// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/product_card.dart';
import 'package:skyewooapp/components/shimmer_shop.dart';
import 'package:skyewooapp/controllers/home_controller.dart';
import 'package:skyewooapp/controllers/products_controller.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/main.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/screens/archive/archive.dart';
import 'package:skyewooapp/screens/browser.dart';
import 'package:skyewooapp/screens/product/product_page.dart';
import 'package:skyewooapp/ui/home/big_banner_shimmer.dart';
import 'package:skyewooapp/ui/home/carousel_banner_shimmer.dart';
import 'package:skyewooapp/ui/home/grid_banner_shimmer.dart';
import 'package:skyewooapp/ui/home/slide_banner_shimmer.dart';
import 'package:skyewooapp/ui/home/thin_banner_shimmer.dart';
import 'package:skyewooapp/screens/shop/shop_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  //controllers
  HomeController homeController = Get.put(HomeController());
  ProductsController productsController =
      Get.put(ProductsController(order_by: "popularity", numPerPage: "20"));

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 180) / 2;
    final double itemWidth = size.width / 2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //big banner
          Obx(() {
            return Visibility(
              visible: homeController.bigBannerEnabled.value,
              child: (() {
                if (homeController.bigBannerLoading.value) {
                  return const BigBannerShimmer();
                } else {
                  return CarouselSlider(
                    items: List.generate(homeController.bigBanners.length,
                        (index) {
                      var banner = homeController.bigBanners[index];
                      return InkWell(
                        onTap: () {
                          if (banner.getOnClickTo == "category") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivePage(
                                  title: banner.getTitle,
                                  slug: banner.getCategory,
                                  subTitle: banner.getDescription,
                                ),
                              ),
                            );
                          } else if (banner.getOnClickTo == "url") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppBrowser(
                                  title: banner.getTitle,
                                  url: banner.getUrl,
                                ),
                              ),
                            );
                          } else if (banner.onClickTo == "shop") {
                            MyHomePage.changeBody(context, 1);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(0),
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: AppColors.f1,
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: (() {
                              if (banner.getImage.isNotEmpty &&
                                  banner.getImage != "false" &&
                                  Uri.parse(banner.getImage).isAbsolute) {
                                return CachedNetworkImage(
                                  memCacheHeight: 600,
                                  memCacheWidth: 600,
                                  imageUrl: banner.getImage,
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
                                      const Padding(
                                    padding: EdgeInsets.all(80.0),
                                    child: Icon(Icons.error),
                                  ),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(80.0),
                                  child: Icon(Icons.error),
                                );
                              }
                            })(),
                          ),
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.width,
                      viewportFraction: 1,
                      scrollDirection: Axis.horizontal,
                      autoPlay: true,
                    ),
                  );
                }
              }()),
            );
          }),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "New Releases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 25,
                  child: TextButton(
                    style: AppStyles.inlineFlatButtonStyle(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 0,
                        top: 0,
                      ),
                      radius: 50,
                      backgroundColor: Colors.white,
                      primary: Colors.black,
                    ),
                    onPressed: () {
                      //push
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopPage(orderBy: "date"),
                        ),
                      ).then((value) {
                        MyHomePage.resetAppBar(context);
                      });
                    },
                    child: const Text(
                      "View All",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("2021/2022"),
          ),
          const SizedBox(height: 10),

          //slide banner
          Obx(() {
            return Visibility(
              visible: homeController.slideBannerEnabled.value,
              child: (() {
                if (homeController.slideBannerLoading.value) {
                  return const SlideBannerShimmer();
                } else {
                  return CarouselSlider(
                    items: List.generate(homeController.slideBanners.length,
                        (index) {
                      var banner = homeController.slideBanners[index];
                      return InkWell(
                        onTap: () {
                          if (banner.getOnClickTo == "category") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivePage(
                                  title: banner.getTitle,
                                  slug: banner.getCategory,
                                  subTitle: banner.getDescription,
                                ),
                              ),
                            );
                          } else if (banner.getOnClickTo == "url") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppBrowser(
                                  title: banner.getTitle,
                                  url: banner.getUrl,
                                ),
                              ),
                            );
                          } else if (banner.onClickTo == "shop") {
                            MyHomePage.changeBody(context, 1);
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              height: 200,
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.only(right: 9),
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                color: AppColors.f1,
                              ),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: (() {
                                  if (banner.getImage.isNotEmpty &&
                                      banner.getImage != "false" &&
                                      Uri.parse(banner.getImage).isAbsolute) {
                                    return CachedNetworkImage(
                                      memCacheHeight: 250,
                                      memCacheWidth: 300,
                                      imageUrl: banner.getImage,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: AppColors.f1,
                                        highlightColor: Colors.white,
                                        period:
                                            const Duration(milliseconds: 500),
                                        child: Container(
                                          color: AppColors.hover,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Padding(
                                        padding: EdgeInsets.all(80.0),
                                        child: Icon(Icons.error),
                                      ),
                                    );
                                  } else {
                                    return const Padding(
                                      padding: EdgeInsets.all(80.0),
                                      child: Icon(Icons.error),
                                    );
                                  }
                                })(),
                              ),
                            ),
                            Positioned(
                              right: 9,
                              bottom: 20,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 20,
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner.getTitle.replaceAll("\\", ""),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(banner.getDescription
                                        .replaceAll("\\", "")),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      //dont touch this settings to avoid crashing
                      height: 200,
                      scrollDirection: Axis.horizontal,
                      viewportFraction: 0.7,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      aspectRatio: 2.0,
                    ),
                  );
                }
              }()),
            );
          }),

          const SizedBox(height: 10),

          //thin banners
          Obx(() {
            return Visibility(
              visible: homeController.thinBannerEnabled.value,
              child: (() {
                if (homeController.thinBannerLoading.value) {
                  return const ThinBannerShimmer();
                } else {
                  return CarouselSlider(
                    items: List.generate(homeController.thinBanners.length,
                        (index) {
                      var banner = homeController.thinBanners[index];
                      return InkWell(
                        onTap: () {
                          if (banner.getOnClickTo == "category") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivePage(
                                  title: banner.getTitle,
                                  slug: banner.getCategory,
                                  subTitle: banner.getDescription,
                                ),
                              ),
                            );
                          } else if (banner.getOnClickTo == "url") {
                            //push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppBrowser(
                                  title: banner.getTitle,
                                  url: banner.getUrl,
                                ),
                              ),
                            );
                          } else if (banner.onClickTo == "shop") {
                            MyHomePage.changeBody(context, 1);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(0),
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: AppColors.f1,
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: (() {
                              if (banner.getImage.isNotEmpty &&
                                  banner.getImage != "false" &&
                                  Uri.parse(banner.getImage).isAbsolute) {
                                return CachedNetworkImage(
                                  imageUrl: banner.getImage,
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
                                      const Padding(
                                    padding: EdgeInsets.all(80.0),
                                    child: Icon(Icons.error),
                                  ),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(80.0),
                                  child: Icon(Icons.error),
                                );
                              }
                            })(),
                          ),
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      height: 100,
                      viewportFraction: 1,
                      scrollDirection: Axis.horizontal,
                      autoPlay: true,
                    ),
                  );
                }
              }()),
            );
          }),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trending",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 25,
                  child: TextButton(
                    style: AppStyles.inlineFlatButtonStyle(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 0,
                        top: 0,
                      ),
                      radius: 50,
                      backgroundColor: Colors.white,
                      primary: Colors.black,
                    ),
                    onPressed: () {
                      //push
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ShopPage(orderBy: "popularity"),
                        ),
                      ).then((value) {
                        MyHomePage.resetAppBar(context);
                      });
                    },
                    child: const Text(
                      "View All",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          //products
          Obx(() {
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
                count: 6,
              );
            } else {
              return productsLayout(itemWidth, itemHeight);
            }

            //end obx
          }),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextButton(
              style: AppStyles.flatButtonStyle(
                radius: 0,
              ),
              child: const Text("View All"),
              onPressed: () {
                //push
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopPage(orderBy: "popularity"),
                  ),
                ).then((value) {
                  MyHomePage.resetAppBar(context);
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          //grid banners
          Obx(() {
            return Visibility(
              visible: homeController.gridBannerEnabled.value,
              child: (() {
                if (homeController.gridBannerLoading.value) {
                  return const GridBannerShimmer();
                } else {
                  return CarouselSlider(
                    items: List.generate(homeController.gridBanners.length,
                        (index) {
                      var banner = homeController.gridBanners[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: InkWell(
                          onTap: () {
                            if (banner.getOnClickTo == "category") {
                              //push
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArchivePage(
                                    title: banner.getTitle,
                                    slug: banner.getCategory,
                                    subTitle: banner.getDescription,
                                  ),
                                ),
                              );
                            } else if (banner.getOnClickTo == "url") {
                              //push
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppBrowser(
                                    title: banner.getTitle,
                                    url: banner.getUrl,
                                  ),
                                ),
                              );
                            } else if (banner.onClickTo == "shop") {
                              MyHomePage.changeBody(context, 1);
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 160,
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              children: [
                                Container(
                                  height: 130,
                                  width: 100,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: AppColors.f1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: (() {
                                      if (banner.getImage.isNotEmpty &&
                                          banner.getImage != "false" &&
                                          Uri.parse(banner.getImage)
                                              .isAbsolute) {
                                        return CachedNetworkImage(
                                          memCacheHeight: 180,
                                          memCacheWidth: 170,
                                          imageUrl: banner.getImage,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: AppColors.f1,
                                            highlightColor: Colors.white,
                                            period: const Duration(
                                                milliseconds: 500),
                                            child: Container(
                                              color: AppColors.hover,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Padding(
                                            padding: EdgeInsets.all(80.0),
                                            child: Icon(Icons.error),
                                          ),
                                        );
                                      } else {
                                        return const Padding(
                                          padding: EdgeInsets.all(80.0),
                                          child: Icon(Icons.error),
                                        );
                                      }
                                    })(),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      banner.getTitle.replaceAll("\\", ""),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      height: 160,
                      scrollDirection: Axis.horizontal,
                      // disableCenter: true,
                      enlargeCenterPage: false,
                      aspectRatio: 2.0,
                      viewportFraction: 0.3,
                    ),
                  );
                }
              }()),
            );
          }),

          const SizedBox(height: 10),

          //carousel banners
          Obx(() {
            return Visibility(
              visible: homeController.carouselBannerEnabled.value,
              child: (() {
                if (homeController.carouselBannerLoading.value) {
                  return const CarouselBannerShimmer();
                } else {
                  return CarouselSlider(
                    items: List.generate(homeController.carouselBanners.length,
                        (index) {
                      var banner = homeController.carouselBanners[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: InkWell(
                          onTap: () {
                            if (banner.getOnClickTo == "category") {
                              //push
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArchivePage(
                                    title: banner.getTitle,
                                    slug: banner.getCategory,
                                    subTitle: banner.getDescription,
                                  ),
                                ),
                              );
                            } else if (banner.getOnClickTo == "url") {
                              //push
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppBrowser(
                                    title: banner.getTitle,
                                    url: banner.getUrl,
                                  ),
                                ),
                              );
                            } else if (banner.onClickTo == "shop") {
                              MyHomePage.changeBody(context, 1);
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: 200,
                            padding: const EdgeInsets.all(0),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: (() {
                                if (banner.getImage.isNotEmpty &&
                                    banner.getImage != "false" &&
                                    Uri.parse(banner.getImage).isAbsolute) {
                                  return CachedNetworkImage(
                                    memCacheHeight: 320,
                                    memCacheWidth: 500,
                                    imageUrl: banner.getImage,
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
                                        const Padding(
                                      padding: EdgeInsets.all(80.0),
                                      child: Icon(Icons.error),
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(80.0),
                                    child: Icon(Icons.error),
                                  );
                                }
                              })(),
                            ),
                          ),
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      height: 200,
                      scrollDirection: Axis.horizontal,
                      enlargeCenterPage: false,
                      viewportFraction: 0.9,
                      autoPlay: true,
                    ),
                  );
                }
              }()),
            );
          }),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Find Us On",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Image.asset("assets/images/collaboration_pic1.png"),
          Image.asset("assets/images/collaboration_pic2.png"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextButton(
                style: AppStyles.flatButtonStyle(
                  radius: 0,
                ),
                child: const Text("Collaborate with us"),
                onPressed: () {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'info@whatsdown.in',
                    query: encodeQueryParameters(
                        <String, String>{'subject': 'WhatsDown Collaboration'}),
                  );

                  launchUrl(emailLaunchUri);
                }),
          ),

          const SizedBox(height: 50),
        ],
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
                    MyHomePage.resetAppBar(context);
                  });
                },
                onWishlistUpdated: () {
                  MyHomePage.resetAppBar(context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
