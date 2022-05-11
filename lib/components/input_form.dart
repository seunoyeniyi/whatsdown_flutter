import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';

class InputForm<T> extends StatefulWidget {
  const InputForm({
    Key? key,
    this.keyboardType = TextInputType.text,
    this.hintText = "",
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.validator,
    this.controller,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.only(left: 15, right: 15),
    this.backgroundColor = Colors.white,
    this.hintTextColor = Colors.black54,
    this.textColor = Colors.black54,
    this.borderColor = AppColors.hover,
    this.radius = 5.0,
    this.borderWidth = 1.0,
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
  final Color hintTextColor;
  final Color textColor;
  final Color borderColor;
  final double radius;
  final double borderWidth;

  final String? Function(String?)? validator;

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  String? val(String val) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          )),
      child: Padding(
        padding: widget.padding,
        child: TextFormField(
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          validator: widget.validator,
          controller: widget.controller,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.textColor,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.hintTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
