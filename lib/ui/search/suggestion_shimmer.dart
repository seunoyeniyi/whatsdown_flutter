import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class SuggestionShimmer extends StatelessWidget {
  const SuggestionShimmer({Key? key}) : super(key: key);

  final Color shimBaseColor = AppColors.f1;
  final Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: shimBaseColor,
                highlightColor: shimHighlightColor,
                period: const Duration(milliseconds: 1000),
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    color: AppColors.f1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: shimBaseColor,
                  highlightColor: shimHighlightColor,
                  period: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    height: 30,
                    child: Container(
                      color: AppColors.f1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
