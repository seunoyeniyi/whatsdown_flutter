import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class CartPageShimmer extends StatelessWidget {
  const CartPageShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: List.generate(7, (index) {
          return Container(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Shimmer.fromColors(
              baseColor: shimBaseColor,
              highlightColor: shimHighlightColor,
              period: const Duration(milliseconds: 1000),
              child: SizedBox(
                height: 100,
                child: Container(
                  color: AppColors.f1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
