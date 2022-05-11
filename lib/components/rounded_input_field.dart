import 'package:flutter/material.dart';
import 'package:skyewooapp/components/text_field_container.dart';
import '../app_colors.dart';

class RoundedInputField extends StatelessWidget {
  const RoundedInputField(
      {Key? key,
      required this.hintText,
      this.icon = Icons.person,
      required this.onChanged,
      this.controller,
      this.keyboardType = TextInputType.text})
      : super(key: key);

  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        onChanged: onChanged,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: AppColors.primary,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
