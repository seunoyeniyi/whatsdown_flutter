import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/category.dart';
import 'package:skyewooapp/screens/archive/archive.dart';
import 'package:skyewooapp/screens/categories/shimmer.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/ui/app_bar.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  AppAppBarController appBarController = AppAppBarController();
  bool isLoading = true;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        controller: appBarController,
        appBarType: "",
        titleType: "title",
        title: "Categories",
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollDirection: Axis.vertical,
          child: (() {
            if (isLoading) {
              return const CategoriesPageShimmer();
            } else if (!isLoading && categories.isEmpty) {
              return Center(
                child: ElevatedButton(
                  child: const Text("Try Again"),
                  onPressed: () {
                    fetchCategories();
                  },
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  right: 10,
                  bottom: 20,
                  left: 10,
                ),
                child: Column(
                  children: List.generate(categories.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        clipBehavior: Clip.hardEdge,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          primary: AppColors.f1,
                          onPrimary: AppColors.hover,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          //push
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArchivePage(
                                title: categories[index].getName,
                                slug: categories[index].getSlug,
                              ),
                            ),
                          ).then((value) {
                            if (appBarController.refreshAll != null) {
                              appBarController.refreshAll!();
                            }
                          });
                        },
                        child: Column(
                          children: [
                            //image
                            Container(
                              height: 200,
                              clipBehavior: Clip.hardEdge,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppColors.f1,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0)),
                              ),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: (() {
                                  if (categories[index].getImage.isNotEmpty &&
                                      categories[index].getImage != "false" &&
                                      Uri.parse(categories[index].getImage)
                                          .isAbsolute) {
                                    return CachedNetworkImage(
                                      memCacheHeight: 380,
                                      memCacheWidth: 380,
                                      imageUrl: categories[index].getImage,
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
                            //title
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                HtmlCharacterEntities.decode(
                                    categories[index].getName),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }
          }()),
        ),
      ),
    );
  }

  fetchCategories() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }

    try {
      setState(() {
        isLoading = true;
        categories = [];
      });

      //fetch

      String url = Site.CATEGORIES +
          "?hide_empty=1&order_by=menu_order" +
          Site.TOKEN_KEY_APPEND;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> json = jsonDecode(response.body);

        for (Map<String, dynamic> category in json) {
          categories.add(Category(
            name: category["name"].toString(),
            slug: category["slug"].toString(),
            count: category["count"].toString(),
            // sub_cats: category["name"].toString(),
            image: category["image"].toString(),
            icon: category["icon"].toString(),
          ));
        }
      } else {
        Toaster.show(message: "Unable to get categories, please try again.");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
