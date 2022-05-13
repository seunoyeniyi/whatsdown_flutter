// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/site.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserSession userSession = UserSession();
  TextStyle labelStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  //controls
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var companyController = TextEditingController();
  var genderController = TextEditingController();
  var dobController = TextEditingController();
  var countryController = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  var stateController = TextEditingController();
  var cityController = TextEditingController();
  var postcodeController = TextEditingController();
  var phoneController = TextEditingController();
  var phone2Controller = TextEditingController();
  var emailController = TextEditingController();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await userSession.init();
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // Add Your Code here.
        fetchAccount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text("First Name", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: firstNameController,
                hintText: "First Name",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Last Name", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: lastNameController,
                hintText: "Last Name",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Company", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: companyController,
                hintText: "Company",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Gender", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: genderController,
                hintText: "Gender",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Date of Birth", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: dobController,
                keyboardType: TextInputType.datetime,
                hintText: "Date of Birth",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              const Text(
                "Address",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text("Country", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: countryController,
                hintText: "Country",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Street Address", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: address1Controller,
                hintText: "House number, and street name",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              InputForm(
                controller: address2Controller,
                hintText: "Apartment, suite, unit etc. (Optional)",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("State", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: stateController,
                hintText: "State",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("City", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: cityController,
                hintText: "City",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Post code", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: postcodeController,
                hintText: "Post code",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Phone", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                hintText: "Phone",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              InputForm(
                controller: phone2Controller,
                keyboardType: TextInputType.phone,
                hintText: "Alternate Phone",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              Text("Email", style: labelStyle),
              const SizedBox(height: 10),
              InputForm(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "Email",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              TextButton(
                style: AppStyles.flatButtonStyle(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                ),
                onPressed: () {
                  saveAccount();
                },
                child: const Text(
                  "SAVE",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  fetchAccount() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    SmartDialog.show(clickBgDismissTemp: false, widget: const LoadingBox());
    try {
      //fetch
      String url = Site.USER + userSession.ID + "?token_key=" + Site.TOKEN_KEY;
      Response response = await get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Map<String, dynamic> address = json["shipping_address"];
        firstNameController.text = address["shipping_first_name"].toString();
        lastNameController.text = address["shipping_last_name"].toString();
        companyController.text = address["shipping_company"].toString();
        genderController.text = address["gender"].toString();
        dobController.text = address["birthday"].toString();
        address1Controller.text = address["shipping_address_1"].toString();
        address2Controller.text = address["shipping_address_2"].toString();
        cityController.text = address["shipping_city"].toString();
        stateController.text = address["shipping_state"].toString();
        postcodeController.text = address["shipping_postcode"].toString();
        countryController.text = address["shipping_country"].toString();
        phoneController.text = address["shipping_phone"].toString();
        phone2Controller.text = address["other_phone"].toString();
        emailController.text = address["shipping_email"].toString();
      } else {
        Toaster.show(
          message: "Can't fetch your address, Try to go back.",
          gravity: ToastGravity.TOP,
        );
      }
    } finally {
      SmartDialog.dismiss();
    }
  }

  saveAccount() async {
    FocusScope.of(context).unfocus();
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }

    if (firstNameController.text.isEmpty) {
      Toaster.show(
        message: "First name required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (lastNameController.text.isEmpty) {
      Toaster.show(
        message: "Last name required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (countryController.text.isEmpty) {
      Toaster.show(
        message: "Country required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (address1Controller.text.isEmpty) {
      Toaster.show(
        message: "Address required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (cityController.text.isEmpty) {
      Toaster.show(
        message: "City required!!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (phoneController.text.isEmpty) {
      Toaster.show(
        message: "Phone required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (emailController.text.isEmpty) {
      Toaster.show(
        message: "Email is required!",
        gravity: ToastGravity.TOP,
      );
      return;
    }
    if (!isValidEmail(emailController.text)) {
      Toaster.show(
        message: "Enter a valid email!",
        gravity: ToastGravity.TOP,
      );
      return;
    }

    SmartDialog.show(clickBgDismissTemp: false, widget: const LoadingBox());
    try {
      //fetch
      String url = Site.UPDATE_SHIPPING + userSession.ID;

      dynamic data = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "company": companyController.text,
        "gender": genderController.text,
        "birthday": dobController.text,
        "country": countryController.text,
        "state": stateController.text,
        "city": cityController.text,
        "postcode": postcodeController.text,
        "address_1": address1Controller.text,
        "address_2": address2Controller.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "other_phone": phone2Controller.text,
        "token_key": Site.TOKEN_KEY,
      };
      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json["code"].toString() == "saved") {
          Toaster.show(
            message: "Address saved!",
            gravity: ToastGravity.TOP,
          );
        } else {
          //not saved
          Toaster.show(
            message: "Address not  saved!",
            gravity: ToastGravity.TOP,
          );
        }
      } else {
        Toaster.show(message: "Unable to save address.");
      }
    } finally {
      SmartDialog.dismiss();
    }
  }
}
