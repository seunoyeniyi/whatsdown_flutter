import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class SlideBannerShimmer extends StatelessWidget {
  const SlideBannerShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          //one
          Container(
            width: 250,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
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

          //two
          Container(
            width: 250,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
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
        ],
      ),
    );
  }
}
