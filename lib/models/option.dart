class Option {
  String? name;
  String? value;

  Option({this.name, this.value});

  String get getName => name!;

  set setName(String name) => this.name = name;

  String get getValue => value!;

  set setValue(String value) => this.value = value;
}
