import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';

class InputFormTextField<T> extends StatefulWidget {
  const InputFormTextField({
    Key? key,
    this.keyboardType = TextInputType.text,
    this.hintText = "",
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.controller,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.only(left: 15, right: 15),
    this.backgroundColor = Colors.white,
    this.focusNode,
  }) : super(key: key);

  final TextInputType keyboardType;
  final String hintText;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextEditingController? controller;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final FocusNode? focusNode;

  @override
  State<InputFormTextField> createState() => _InputFormTextFieldState();
}

class _InputFormTextFieldState extends State<InputFormTextField> {
  String? val(String val) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: AppColors.hover)),
      child: Padding(
        padding: widget.padding,
        child: TextField(
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          controller: widget.controller,
          style: TextStyle(
              fontSize: widget.fontSize, fontWeight: widget.fontWeight),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }
}
