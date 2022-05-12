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
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Username",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
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
      ),
    );
  }
}
