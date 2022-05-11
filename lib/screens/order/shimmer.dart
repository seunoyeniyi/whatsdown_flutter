import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class OrderPageShimmer extends StatelessWidget {
  const OrderPageShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.white;
  final Color shimHighlightColor = AppColors.f1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 50,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 20,
            width: 100,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 1),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 30,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: shimBaseColor,
          highlightColor: shimHighlightColor,
          period: const Duration(milliseconds: 1000),
          child: Container(
            color: AppColors.f1,
            height: 200,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
