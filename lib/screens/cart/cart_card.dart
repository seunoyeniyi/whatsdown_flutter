import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/formatter.dart';
import 'package:skyewooapp/models/cart_item.dart';
import 'package:skyewooapp/site.dart';

class CartCard extends StatefulWidget {
  const CartCard({
    Key? key,
    required this.item,
    required this.onChanged,
  }) : super(key: key);

  final CartItem item;
  final Function(int quantity) onChanged;

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  int quantity = 1;
  double subtotal = 0;

  @override
  void initState() {
    super.initState();
    quantity = int.parse(widget.item.getQuantity);
    subtotal = double.parse(
            widget.item.getPrice.isEmpty ? "0" : widget.item.getPrice) *
        quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //image
          Container(
            height: 100,
            width: 100,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: AppColors.f1,
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: BoxFit.cover,
              child: (() {
                if (widget.item.getImage.isNotEmpty &&
                    widget.item.getImage != "false" &&
                    Uri.parse(widget.item.getImage).isAbsolute) {
                  return CachedNetworkImage(
                    memCacheHeight: 200,
                    memCacheWidth: 200,
                    imageUrl: widget.item.getImage,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.f1,
                      highlightColor: Colors.white,
                      period: const Duration(milliseconds: 500),
                      child: Container(
                        color: AppColors.hover,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Padding(
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
          const SizedBox(width: 5),
          //info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //title
                Text(
                  HtmlCharacterEntities.decode(widget.item.getName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                //pricing
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      Site.CURRENCY + Formatter.format(widget.item.getPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Visibility(
                      visible: quantity > 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          Text("x" + quantity.toString() + "="),
                          const SizedBox(width: 5),
                          Text(
                            Site.CURRENCY + Formatter.format(subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //action
                const SizedBox(height: 10),
                Row(
                  children: [
                    CartStepper<int>(
                      count: quantity,
                      size: 30,
                      didChangeCount: (count) {
                        setState(() {
                          if (count > 0) {
                            quantity = count;
                            subtotal = double.parse(widget.item.getPrice.isEmpty
                                    ? "0"
                                    : widget.item.getPrice) *
                                quantity;
                          } else {
                            quantity = 1;
                            subtotal =
                                double.parse(widget.item.getPrice) * quantity;
                          }
                          widget.onChanged(quantity); //update quantity
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      child: TextButton(
                        onPressed: () {
                          widget.onChanged(0); //remove
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          side: const BorderSide(
                            color: AppColors.f1,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        child: const Text(
                          "Remove",
                          style: TextStyle(
                            color: AppColors.link,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
