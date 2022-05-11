import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class CategoriesPageShimmer extends StatelessWidget {
  const CategoriesPageShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: List.generate(5, (index) {
          return Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: shimBaseColor,
                  highlightColor: shimHighlightColor,
                  period: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    height: 200,
                    child: Container(
                      color: AppColors.f1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: shimBaseColor,
                  highlightColor: shimHighlightColor,
                  period: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    height: 25,
                    child: Container(
                      color: AppColors.f1,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
