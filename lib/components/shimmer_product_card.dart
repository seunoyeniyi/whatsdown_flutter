import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';

class ShimmerProductCard extends StatefulWidget {
  const ShimmerProductCard({Key? key}) : super(key: key);

  @override
  State<ShimmerProductCard> createState() => _ShimmerProductCardState();
}

class _ShimmerProductCardState extends State<ShimmerProductCard> {
  Color shimBaseColor = AppColors.f1;
  Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            primary: Colors.white,
            onPrimary: AppColors.hover,
            shadowColor: Colors.transparent,
          ),
          onPressed: () => {},
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: shimBaseColor,
                highlightColor: shimHighlightColor,
                period: const Duration(milliseconds: 1000),
                child: Container(
                  height: 170,
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.f1,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                width: double.infinity,
                padding:
                    const EdgeInsets.only(top: 8, right: 0, bottom: 8, left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: shimBaseColor,
                          highlightColor: shimHighlightColor,
                          period: const Duration(milliseconds: 1000),
                          child: SizedBox(
                            height: 20,
                            width: 30,
                            child: Container(
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Shimmer.fromColors(
                          baseColor: shimBaseColor,
                          highlightColor: shimHighlightColor,
                          period: const Duration(milliseconds: 1000),
                          child: SizedBox(
                            height: 20,
                            width: 30,
                            child: Container(
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 120,
          child: Shimmer.fromColors(
            baseColor: shimHighlightColor,
            highlightColor: shimBaseColor,
            period: const Duration(milliseconds: 1000),
            child: ElevatedButton(
              onPressed: () {},
              child: SvgPicture.asset(
                "assets/icons/icons8_heart.svg",
                width: 17,
                height: 17,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                shape: const CircleBorder(),
                padding:
                    const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 6),
                primary: Colors.white, // <-- Button color
                onPrimary: AppColors.black, // <-- Splash color
              ),
            ),
          ),
        ),
      ],
    );
  }
}
