import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class GridBannerShimmer extends StatelessWidget {
  const GridBannerShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          return Container(
            width: 100,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            margin: const EdgeInsets.only(right: 10),
            child: Shimmer.fromColors(
              baseColor: shimBaseColor,
              highlightColor: shimHighlightColor,
              period: const Duration(milliseconds: 1000),
              child: SizedBox(
                height: 150,
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
