class Country {
  String code;
  String name;

  Country({required this.code, required this.name});

  String get getCode => code;

  set setCode(String code) => this.code = code;

  String get getName => name;

  set setName(String name) => this.name = name;
}
