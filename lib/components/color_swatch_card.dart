import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

class ColorSwatchCard extends StatefulWidget {
  const ColorSwatchCard({
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
  State<ColorSwatchCard> createState() => _ColorSwatchCardState();
}

class _ColorSwatchCardState extends State<ColorSwatchCard> {
  List<Map<String, Color>> registeredColros = [
    {"white": Colors.white},
    {"blue": Colors.blue},
    {"red": Colors.red},
    {"green": Colors.green},
    {"black": Colors.black},
    {"orange": Colors.orange},
    {"pink": Colors.pink},
    {"purple": Colors.purple},
    {"yellow": Colors.yellow},
    {"blue-corban": const Color(0xFF314174)},
    {"gray": const Color(0xFF808080)},
    {"grey": Colors.grey},
    {"navyblue": const Color(0xFF000080)},
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: DottedBorder(
        dashPattern: const [6, 6],
        color: widget.selected ? Colors.black : Colors.transparent,
        strokeWidth: widget.selected ? 3 : 0,
        borderType: BorderType.Rect,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: (() {
              for (var element in registeredColros) {
                if (element.containsKey(widget.slug)) {
                  return element[widget.slug];
                }
              }
              return Colors.white;
            }()),
          ),
          child: Center(
            child: Text(
              HtmlCharacterEntities.decode(widget.name),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: (() {
                  for (var element in registeredColros) {
                    if (element.containsKey(widget.slug) &&
                        widget.slug != "white") {
                      return Colors.white;
                    }
                  }
                  return Colors.black;
                }()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
