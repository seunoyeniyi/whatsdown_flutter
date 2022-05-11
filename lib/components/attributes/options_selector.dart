import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/models/option.dart';

class OptionSelector extends StatefulWidget {
  const OptionSelector({
    Key? key,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  final List<Option> options;
  final Function(String name) onSelected;

  @override
  State<OptionSelector> createState() => _OptionSelectorState();
}

class _OptionSelectorState extends State<OptionSelector> {
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
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.hover,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<Option>(
            isExpanded: true,
            value: widget.options[selectedIndex],
            icon: const Icon(Icons.arrow_drop_down),
            items: widget.options.map((Option item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  HtmlCharacterEntities.decode(item.getValue),
                ),
              );
            }).toList(),
            onChanged: (Option? value) {
              setState(() {
                selectedIndex = widget.options.indexOf(value!);
                widget.onSelected(value.getName);
              });
            },
            underline: const SizedBox(),
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No Opton available"),
      );
    }
  }
}
