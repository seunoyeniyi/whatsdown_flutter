import 'package:flutter/material.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
    this.controller,
  }) : super(key: key);

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        onChanged: onChanged,
        obscureText: true,
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: AppColors.primary,
          ),
          // suffixIcon: Icon(
          //   Icons.visibility,
          //   color: AppColors.primary,
          // ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
