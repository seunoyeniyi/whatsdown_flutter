// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/models/product.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    Key? key,
    required this.product,
    required this.onSelected,
  }) : super(key: key);

  final Product product;
  final Function(Product product) onSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(2),
      ),
      onPressed: () {
        onSelected(product);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: (() {
              if (product.getImage.isNotEmpty &&
                  product.getImage != "false" &&
                  Uri.parse(product.getImage).isAbsolute) {
                return CachedNetworkImage(
                  memCacheHeight: 100,
                  memCacheWidth: 100,
                  imageUrl: product.getImage,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.f1,
                    highlightColor: Colors.white,
                    period: const Duration(milliseconds: 500),
                    child: Container(
                      color: AppColors.hover,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.error),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.search),
                );
              }
            })(),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Center(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  product.getName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
