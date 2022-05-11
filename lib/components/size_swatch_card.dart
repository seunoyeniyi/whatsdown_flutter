import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:skyewooapp/app_colors.dart';

class SizeSwatchCard extends StatefulWidget {
  const SizeSwatchCard({
    Key? key,
    required this.name,
    required this.slug,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final String slug;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<SizeSwatchCard> createState() => _SizeSwatchCardState();
}

class _SizeSwatchCardState extends State<SizeSwatchCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.selected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: AppColors.f1,
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: Text(
            HtmlCharacterEntities.decode(() {
              if (["s", "small", "small-26-28-inches"]
                  .contains(widget.slug.toLowerCase())) {
                return "S";
              } else if (["medium", "m", "medium-29-31-inches"]
                  .contains(widget.slug.toLowerCase())) {
                return "M";
              } else if (["large", "l", "large-32-34-inches"]
                  .contains(widget.slug.toLowerCase())) {
                return "L";
              } else if (["extra-large", "xl", "extra-large-35-37-inches"]
                  .contains(widget.slug.toLowerCase())) {
                return "XL";
              } else if (["xxl", "extra-extra-large"]
                  .contains(widget.slug.toLowerCase())) {
                return "XXL";
              } else if (["2xl", "2-x-extra-large"]
                  .contains(widget.slug.toLowerCase())) {
                return "2XL";
              } else {
                return widget.name.toUpperCase();
              }
            }()),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: widget.selected ? AppColors.onPrimary : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
