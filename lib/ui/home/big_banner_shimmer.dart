import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class BigBannerShimmer extends StatelessWidget {
  const BigBannerShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Shimmer.fromColors(
        baseColor: shimBaseColor,
        highlightColor: shimHighlightColor,
        period: const Duration(milliseconds: 1000),
        child: SizedBox(
          height: MediaQuery.of(context).size.width,
          child: Container(
            color: AppColors.f1,
          ),
        ),
      ),
    );
  }
}
