import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skyewooapp/components/attributes/options_selector.dart';
import 'package:skyewooapp/components/attributes/size_option_selector.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/models/attribute.dart';

class AttributesSelector extends StatefulWidget {
  const AttributesSelector({
    Key? key,
    required this.attributes,
    required this.variations,
    required this.onChanged,
  }) : super(key: key);

  final List<Attribute> attributes;
  final List<Map<String, dynamic>> variations;
  final Function(bool found, String productID, String price) onChanged;

  @override
  State<AttributesSelector> createState() => _AttributesSelectorState();
}

class _AttributesSelectorState extends State<AttributesSelector> {
  Map<String, String> selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    if (widget.attributes.isNotEmpty) {
      return Column(
        children: List.generate(widget.attributes.length, (attrIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.attributes[attrIndex].getLabel.capitalize(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              (() {
                if (widget.attributes[attrIndex].getName == "pa_size" ||
                    widget.attributes[attrIndex].getLabel.toLowerCase() ==
                        "size") {
                  return SizeOptionSelector(
                    options: widget.attributes[attrIndex].getOptions,
                    onSelected: (String name) {
                      String paAttributeName =
                          widget.attributes[attrIndex].getName;
                      selectedOptions[paAttributeName] = name;
                      findMatchedVariation();
                    },
                  );
                } else {
                  return OptionSelector(
                    options: widget.attributes[attrIndex].getOptions,
                    onSelected: (String name) {
                      String paAttributeName =
                          widget.attributes[attrIndex].getName;
                      selectedOptions[paAttributeName] = name;
                      findMatchedVariation();
                    },
                  );
                }
              }()),
            ],
          );
        }),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No option availble"),
      );
    }
  }

  findMatchedVariation() {
    bool found = false;
    String productID = "0";
    String price = "0";

    //for each variations
    for (var variation in widget.variations) {
      //options from this current variations
      //to be compared with the user selectedOptions
      Map<String, String> comparedOptions = {};

      //get attributes of the current looped variation
      List<Map<String, dynamic>> attributes =
          List.from(variation["attributes"]);

      //for each of the attributes of this current looped variation
      for (var attribute in attributes) {
        attribute.forEach((key, value) {
          comparedOptions[key] = value.toString();
        });
      }
      //compare the user selectedOptions with comparedOptions for this current varation index
      found = mapEquals(selectedOptions, comparedOptions);
      if (found) {
        productID = variation["ID"].toString();
        price = variation["price"].toString();
        break;
      }
    }

    widget.onChanged(found, productID, price);
  }
}
