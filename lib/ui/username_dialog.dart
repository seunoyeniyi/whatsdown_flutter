import 'package:flutter/material.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/handlers/app_styles.dart';

class UsernameDialog extends StatefulWidget {
  const UsernameDialog({Key? key}) : super(key: key);

  @override
  State<UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<UsernameDialog> {
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              InputForm(
                controller: usernameController,
                hintText: "Username",
              ),
              const SizedBox(height: 10),
              TextButton(
                style: AppStyles.flatButtonStyle(),
                onPressed: () {
                  Navigator.pop(context, usernameController.text);
                },
                child: const Text("SUBMIT"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
