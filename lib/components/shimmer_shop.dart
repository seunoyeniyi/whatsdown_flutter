import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/shimmer_product_card.dart';

class ShopShimmer extends StatefulWidget {
  const ShopShimmer({
    Key? key,
    required this.itemWidth,
    required this.itemHeight,
    this.count = 8,
  }) : super(key: key);

  final double itemWidth;
  final double itemHeight;
  final int count;

  @override
  State<ShopShimmer> createState() => _ShopShimmerState();
}

class _ShopShimmerState extends State<ShopShimmer> {
  Color shimBaseColor = AppColors.f1;
  Color shimHighlightColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: (widget.itemWidth / widget.itemHeight),
        children: List.generate(widget.count, (index) {
          return const ShimmerProductCard();
        }),
      ),
    );
  }
}
