import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class CarouselBannerShimmer extends StatelessWidget {
  const CarouselBannerShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Shimmer.fromColors(
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
      ),
    );
  }
}
