// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:http/http.dart';
import 'package:skyewooapp/components/input_form.dart';
import 'package:skyewooapp/components/input_form_textfield.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/country.dart';
import 'package:skyewooapp/models/country_states.dart';
import 'package:skyewooapp/models/state.dart' as mystate;
import 'package:skyewooapp/site.dart';

class CheckoutAddressPage extends StatefulWidget {
  const CheckoutAddressPage({Key? key}) : super(key: key);

  @override
  State<CheckoutAddressPage> createState() => _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends State<CheckoutAddressPage> {
  //session
  UserSession userSession = UserSession();

  //countiries and states list
  List<Country> countries = [];
  List<mystate.State> states = [];
  List<CountryStates> itStates = [];

  //label style
  TextStyle labelStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  //controls
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var companyController = TextEditingController();
  var countryController = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  var stateController = TextEditingController();
  var cityController = TextEditingController();
  var postcodeController = TextEditingController();
  var phoneController = TextEditingController();
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
        fetchCart();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Delivery Address",
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
              const SizedBox(height: 20),
              const Text(
                "Shipping",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text("Country", style: labelStyle),
              const SizedBox(height: 10),
              Autocomplete(
                onSelected: (Country country) {
                  //set states dropdown
                  setState(() {
                    stateController.text = "";
                    itStates = getCountryStates(country.getCode, states);
                  });
                },
                //search matching
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return countries
                      .where((Country counry) => counry.getName
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                //custom text field
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  countryController = fieldTextEditingController;
                  return InputFormTextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    hintText: "Country",
                    fontSize: 18,
                  );
                },
                //displayed string
                displayStringForOption: (Country option) =>
                    HtmlCharacterEntities.decode(option.getName),
              ),

              const SizedBox(height: 10),
              //sate
              Text("State", style: labelStyle),
              const SizedBox(height: 10),
              Autocomplete(
                onSelected: (CountryStates cs) {
                  setState(() {
                    stateController.text = cs.getName;
                  });
                },
                //search matching
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return itStates
                      .where((CountryStates cs) => cs.getName
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                //custom text field
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  stateController = fieldTextEditingController;
                  return InputFormTextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    hintText: "State",
                    fontSize: 18,
                  );
                },
                //displayed string
                displayStringForOption: (CountryStates option) =>
                    HtmlCharacterEntities.decode(option.getName),
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
              // InputForm(
              //   controller: phone2Controller,
              //   keyboardType: TextInputType.phone,
              //   hintText: "Other Phone",
              //   fontSize: 18,
              // ),
              // const SizedBox(height: 10),
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
                  saveAddress();
                },
                child: const Text(
                  "PROCEED TO PAYMENT",
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

  fetchCart() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);

    //fetch
    String url = Site.CART + userSession.ID + "?token_key=" + Site.TOKEN_KEY;
    Response response = await get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(response.body);
      if (json.containsKey("items")) {
        if (List.from(json["items"]).isEmpty) {
          cartIsEmpty();
        } else {
          fetchAddress();
        }
      } else {
        cartIsEmpty();
      }
    } else {
      Toaster.show(message: "Unable to get your cart.");
      Navigator.pop(context);
    }
  }

  cartIsEmpty() {
    Toaster.show(message: "Your Cart is empty.");
    Navigator.pop(context);
  }

  fetchAddress() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      Navigator.pop(context);
      return;
    }
    try {
      String url = Site.USER +
          userSession.ID +
          "?with_regions=1" +
          Site.TOKEN_KEY_APPEND;
      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Map<String, dynamic> address = json["shipping_address"];
        firstNameController.text = address["shipping_first_name"].toString();
        lastNameController.text = address["shipping_last_name"].toString();
        companyController.text = address["shipping_company"].toString();
        address1Controller.text = address["shipping_address_1"].toString();
        address2Controller.text = address["shipping_address_2"].toString();
        cityController.text = address["shipping_city"].toString();
        stateController.text = address["shipping_state"].toString();
        postcodeController.text = address["shipping_postcode"].toString();
        countryController.text = address["shipping_country"].toString();
        phoneController.text = address["shipping_phone"].toString();
        emailController.text = address["shipping_email"].toString();

        //setup regions and state
        Map<String, dynamic> regions = json["regions"];
        Map<String, dynamic> jsonCountries = regions["countries"];
        Map<String, dynamic> jsonStates = regions["states"];

        countries.clear();
        states.clear();
        //add countries
        jsonCountries.forEach((key, value) {
          countries.add(Country(code: key, name: value.toString()));
        });
        //add states
        jsonStates.forEach((key, value) {
          //get all states of the country key
          List<CountryStates> countryStates = [];
          var countryStatesObject = jsonStates[key];
          if (countryStatesObject is Map ||
              countryStatesObject is Map<String, dynamic>) {
            // Map<String, dynamic> countryStatesJson = countryStatesObject;
            (countryStatesObject as Map).forEach((key, value) {
              countryStates.add(CountryStates(name: value.toString()));
            });
          }

          //add states to country autocomplete
          states.add(mystate.State(countryCode: key, states: countryStates));
        });

        //set default country
        if (address["shipping_country"].toString().isEmpty) {
          setDefaultCountry("India", "IN");
        }

        //end
      } else {
        Toaster.show(message: "Can't get your address, Try again");
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        SmartDialog.dismiss();
        setState(() {});
      }
    }
  }

  List<CountryStates> getCountryStates(
      String countryCode, List<mystate.State> stateLists) {
    for (mystate.State countryS in stateLists) {
      if (countryS.getCountryCode == countryCode) {
        return countryS.getStates;
      }
    }
    return [];
  }

  void setDefaultCountry(String name, String code) {
    countryController.text = name;
    itStates = getCountryStates(code, states);
  }

  saveAddress() async {
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

    SmartDialog.show(widget: const LoadingBox(), clickBgDismissTemp: false);
    try {
      //fetch
      String url = Site.UPDATE_SHIPPING + userSession.ID;
      dynamic data = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "company": companyController.text,
        "country": countryController.text,
        "state": stateController.text,
        "city": cityController.text,
        "postcode": postcodeController.text,
        "address_1": address1Controller.text,
        "address_2": address2Controller.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "token_key=": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json["code"].toString() == "saved") {
          Toaster.show(message: "Address Saved");
          Navigator.pushNamed(context, "payment_checkout")
              .then((value) => fetchCart());
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

      //end
    } finally {
      SmartDialog.dismiss();
      setState(() {});
    }
  }
}
