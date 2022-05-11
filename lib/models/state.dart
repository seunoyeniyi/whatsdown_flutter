import 'package:skyewooapp/models/country_states.dart';

class State {
  String countryCode;
  List<CountryStates> states;

  State({required this.countryCode, required this.states});

  String get getCountryCode => countryCode;

  set setCountryCode(String countryCode) => this.countryCode = countryCode;

  List<CountryStates> get getStates => states;

  set setStates(List<CountryStates> states) => this.states = states;
}
