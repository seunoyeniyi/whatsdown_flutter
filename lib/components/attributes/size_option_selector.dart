import 'package:flutter/material.dart';
import 'package:skyewooapp/components/size_swatch_card.dart';
import 'package:skyewooapp/models/option.dart';

class SizeOptionSelector extends StatefulWidget {
  const SizeOptionSelector({
    Key? key,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  final List<Option> options;
  final Function(String name) onSelected;

  @override
  State<SizeOptionSelector> createState() => _SizeOptionSelectorState();
}

class _SizeOptionSelectorState extends State<SizeOptionSelector> {
  int selectedIndex = 0;

  @override
  void initState() {
    if (widget.options.isNotEmpty) {
      //default auto selection first item
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          // Add Your Code here.
          widget.onSelected(widget.options[selectedIndex].getName);
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isNotEmpty) {
      return GridView.count(
        crossAxisCount: 6,
        mainAxisSpacing: 2,
        crossAxisSpacing: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: List.generate(widget.options.length, (index) {
          return Container(
            margin: const EdgeInsets.all(2),
            child: SizeSwatchCard(
              name: widget.options[index].getValue,
              slug: widget.options[index].getName,
              selected: index == selectedIndex,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  widget.onSelected(widget.options[index].getName);
                });
              },
            ),
          );
        }).toList(),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No Opton available"),
      );
    }
  }
}
