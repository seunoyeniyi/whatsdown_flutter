import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';

class SegmentSelector extends StatefulWidget {
  const SegmentSelector({
    Key? key,
    required this.segments,
    required this.onSelected,
  }) : super(key: key);

  final List<Segment> segments;
  final Function(Segment segment) onSelected;

  @override
  State<SegmentSelector> createState() => _SegmentSelectorState();
}

class _SegmentSelectorState extends State<SegmentSelector> {
  int selectedIndex = 0;
  double radius = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
          ),
          BoxShadow(
            color: Colors.white,
            spreadRadius: -0.0,
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: List.generate(widget.segments.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  primary: selectedIndex == index
                      ? AppColors.onPrimary
                      : Colors.black,
                  backgroundColor: selectedIndex == index
                      ? AppColors.primary
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                  ),
                ),
                onPressed: () {
                  widget.onSelected(widget.segments[index]);
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: widget.segments[index].value,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class Segment {
  String key;
  Widget value;

  Segment({required this.key, required this.value});

  String get getKey => key;

  set setKey(String key) => this.key = key;

  Widget get getValue => value;

  set setValue(Widget value) => this.value = value;
}
