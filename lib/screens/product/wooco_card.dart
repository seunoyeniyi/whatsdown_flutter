// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/attributes/attributes_selector.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/models/attribute.dart';
import 'package:skyewooapp/models/option.dart';
import 'package:skyewooapp/models/product.dart';
import 'package:skyewooapp/site.dart';

class WooCoCard extends StatefulWidget {
  const WooCoCard({
    Key? key,
    required this.product,
    required this.onEachProductChanged,
  }) : super(key: key);

  final Product product;
  final Function(String parentID, String productID) onEachProductChanged;

  @override
  State<WooCoCard> createState() => _WooCoCardState();
}

class _WooCoCardState extends State<WooCoCard> {
  String productPrice = "0";
  bool priceAvailable = false;
  List<Attribute> attributes = [];
  Map<String, String> selectedOptions = {};

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    if (widget.product.getType == "variable" ||
        widget.product.getType == "variable") {
      if (widget.product.getLowestPrice.isNotEmpty) {
        productPrice = widget.product.getLowestPrice;
      } else {
        productPrice = widget.product.getPrice;
      }
      //attributes
      for (Map<String, dynamic> attr in widget.product.attributes) {
        //get each attribute options
        List<Map<String, dynamic>> jsonOptions = List.from(attr["options"]);
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
          name: attr["name"].toString(),
          label: attr["label"].toString(),
          options: option,
        ));
      }
    } else {
      //simple product
      productPrice = widget.product.getPrice;
      priceAvailable = true;
      widget.onEachProductChanged(widget.product.getID, widget.product.getID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              //image
              Container(
                height: 80,
                width: 80,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColors.f1,
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: FittedBox(
                  clipBehavior: Clip.hardEdge,
                  fit: BoxFit.cover,
                  child: (() {
                    if (widget.product.getImage.isNotEmpty &&
                        widget.product.getImage != "false" &&
                        Uri.parse(widget.product.getImage).isAbsolute) {
                      return CachedNetworkImage(
                        memCacheHeight: 120,
                        memCacheWidth: 120,
                        imageUrl: widget.product.getImage,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.f1,
                          highlightColor: Colors.white,
                          period: const Duration(milliseconds: 500),
                          child: Container(
                            color: AppColors.hover,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Icon(Icons.error),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Icon(Icons.error),
                      );
                    }
                  })(),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Center(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.getName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Visibility(
                          visible: widget.product.getType == "variable" ||
                              widget.product.getProductType == "variable",
                          child: AttributesSelector(
                            showLabel: false,
                            attributes: attributes,
                            variations: widget.product.variations,
                            onChanged:
                                (bool found, String productID, String price) {
                              setState(() {
                                priceAvailable = found;
                                productPrice = price;
                                if (found) {
                                  widget.onEachProductChanged(
                                      widget.product.getID, productID);
                                } else {
                                  widget.onEachProductChanged(
                                      widget.product.getID,
                                      widget.product.getID);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Visibility(
            visible: priceAvailable,
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Colors.red,
              child: Text(
                Site.CURRENCY + Formatter.format(productPrice),
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
