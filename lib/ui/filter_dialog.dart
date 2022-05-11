// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/color_swatch_card.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/category.dart';
import 'package:skyewooapp/models/option.dart';
import 'package:skyewooapp/models/tag.dart';
import 'package:skyewooapp/site.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    Key? key,
    this.categories,
    this.tags,
    this.priceRange,
    this.colors,
    this.selectedCatIndex,
    this.selectedColorIndex,
    this.selectedTagIndex,
    this.selected_category,
    this.selected_color,
    this.selected_tag,
  }) : super(key: key);

  final List<Category>? categories;
  final List<Tag>? tags;
  final RangeValues? priceRange;
  final List<Option>? colors;
  final String? selected_category;
  final String? selected_tag;
  final String? selected_color;
  final int? selectedCatIndex;
  final int? selectedTagIndex;
  final int? selectedColorIndex;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  //LIST
  List<Category> categories = [
    Category(name: "All categories", slug: "")
  ]; //default
  List<Tag> tags = [Tag(name: "All tags", slug: "")]; //default
  // List<AttributeTerm> sizes = [AttributeTerm(name: "Any", slug: "")]; //default for size
  List<Option> colors = [Option(name: "", value: "Any")];

  //### DEAULT VALUES
  double initialLower = 100;
  double initialUpper = 13000;
  double maximumPrice = 15000;
  int selectedCatIndex = 0;
  String selected_category = "";
  int selectedTagIndex = 0;
  String selected_tag = "";
  int selectedColorIndex = 0;
  String selected_color = "";
  RangeValues? priceRange;

  //LOADING states
  bool loadingCategories = true, loadingColors = true, loadingTags = true;

  @override
  void initState() {
    priceRange = RangeValues(initialLower, initialUpper);

    if (widget.categories != null) {
      categories = widget.categories!;
      loadingCategories = false;
    } else {
      fetchCategories();
    }

    if (widget.colors != null) {
      colors = widget.colors!;
      loadingColors = false;
    } else {
      fetchColors();
    }

    if (widget.priceRange != null) {
      priceRange = widget.priceRange!;
    }

    if (widget.tags != null) {
      tags = widget.tags!;
      loadingTags = false;
    } else {
      fetchTags();
    }

    //indexs
    if (widget.selectedCatIndex != null) {
      selectedCatIndex = widget.selectedCatIndex!;
    }
    if (widget.selectedColorIndex != null) {
      selectedColorIndex = widget.selectedColorIndex!;
    }
    if (widget.selectedTagIndex != null) {
      selectedTagIndex = widget.selectedTagIndex!;
    }

    //selected slug
    if (widget.selected_category != null) {
      selected_category = widget.selected_category!;
    }
    if (widget.selected_tag != null) {
      selected_tag = widget.selected_tag!;
    }
    if (widget.selected_color != null) {
      selected_color = widget.selected_color!;
    }

    //don't use widget.any-value after this line

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: const [
            Icon(
              Icons.sort,
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              "Filter",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: contentBox(context),
      ),
    );
  }

  contentBox(context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //######Category#######
              const Text(
                " Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.hover,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<Category>(
                        isExpanded: true,
                        value: categories[selectedCatIndex],
                        icon: const Icon(Icons.arrow_drop_down),
                        items: categories.map((Category item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              HtmlCharacterEntities.decode(item.getName),
                            ),
                          );
                        }).toList(),
                        onChanged: (Category? value) {
                          setState(() {
                            selectedCatIndex = categories.indexOf(value!);
                            selected_category = value.getSlug;
                          });
                        },
                        underline: const SizedBox(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: loadingCategories,
                    child: const Positioned(
                      top: 14,
                      right: 7,
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              //######End Category#######

              //######Colour#######
              const Text(
                "Colour",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.hover,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GridView.count(
                      crossAxisCount: 5,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(colors.length, (index) {
                        return Container(
                          margin: const EdgeInsets.all(2),
                          child: ColorSwatchCard(
                            name: colors[index].getValue,
                            slug: colors[index].getName,
                            selected: index == selectedColorIndex,
                            onTap: () {
                              setState(() {
                                selectedColorIndex = index;
                                selected_color = colors[index].getName;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Visibility(
                    visible: loadingColors,
                    child: const Positioned(
                      top: 30,
                      right: 30,
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //######End Colour#######

              //######Price#######
              const Text(
                " Price",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.hover,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        Site.CURRENCY +
                            priceRange!.start.round().toString() +
                            " - " +
                            Site.CURRENCY +
                            priceRange!.end.round().toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    RangeSlider(
                      min: 0,
                      max: maximumPrice,
                      values: priceRange!,
                      divisions: 20,
                      labels: RangeLabels(
                        priceRange!.start.round().toString(),
                        priceRange!.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          priceRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              //######End Price#######

              //######Tag#######
              const Text(
                " Tag",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.hover,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<Tag>(
                        isExpanded: true,
                        value: tags[selectedTagIndex],
                        icon: const Icon(Icons.arrow_drop_down),
                        items: tags.map((Tag item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                                HtmlCharacterEntities.decode(item.getName)),
                          );
                        }).toList(),
                        onChanged: (Tag? value) {
                          setState(() {
                            selectedTagIndex = tags.indexOf(value!);
                            selected_tag = value.getSlug;
                          });
                        },
                        underline: const SizedBox(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: loadingTags,
                    child: const Positioned(
                      top: 14,
                      right: 7,
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //######End Tag#######

              const SizedBox(height: 30),

              TextButton(
                style: AppStyles.flatButtonStyle(),
                onPressed: () {
                  Navigator.pop(context, {
                    "categories": categories,
                    "tags": tags,
                    "colors": colors,
                    "price_range":
                        (priceRange! == RangeValues(initialLower, initialUpper))
                            ? null
                            : priceRange,
                    "selected_category": selected_category,
                    "selected_tag": selected_tag,
                    "selected_color": selected_color,
                    "selected_cat_index": selectedCatIndex,
                    "selected_tag_index": selectedTagIndex,
                    "selected_color_index": selectedColorIndex,
                  });
                },
                child: const Text(
                  "Apply Filter",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void fetchCategories() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      loadingCategories = true;
      if (mounted) {
        setState(() {});
      }
      //fetch

      String url = Site.CATEGORIES +
          "?hide_empty=1&order_by=menu_order" +
          "&token_key=" +
          Site.TOKEN_KEY;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> json = jsonDecode(response.body);

        for (var category in json) {
          categories.add(Category(
            name: category["name"].toString(),
            slug: category["slug"].toString(),
            count: "",
            sub_cats: "",
            image: "",
            icon: "",
          ));
        }
      } else {
        Toaster.show(message: "Can't get categories.");
      }
    } finally {
      loadingCategories = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void fetchColors() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      loadingColors = true;
      if (mounted) {
        setState(() {});
      }
      //fetch

      String url =
          Site.ATTRIBUTES + "?name=color" + "&token_key=" + Site.TOKEN_KEY;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<Map<String, dynamic>> terms = List.from(json["terms"]);
        for (var term in terms) {
          colors.add(Option(
            value: term["name"].toString(),
            name: term["slug"].toString(),
          ));
        }
      } else {
        Toaster.show(message: "Can't get colors.");
      }
    } finally {
      loadingColors = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void fetchTags() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    try {
      loadingTags = true;
      if (mounted) {
        setState(() {});
      }
      //fetch

      String url = Site.TAGS +
          "?hide_empty=1&order_by=menu_order" +
          "&token_key=" +
          Site.TOKEN_KEY;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> json = jsonDecode(response.body);

        for (var tag in json) {
          tags.add(Tag(
            name: tag["name"].toString(),
            slug: tag["slug"].toString(),
          ));
        }
      } else {
        Toaster.show(message: "Can't get tags.");
      }
    } finally {
      loadingTags = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
