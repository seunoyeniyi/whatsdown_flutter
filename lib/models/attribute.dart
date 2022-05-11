import 'package:skyewooapp/models/option.dart';

class Attribute {
  String? name;
  List<Option>? options;
  String? label;

  Attribute({this.name, this.label, this.options});

  String get getName => name!;

  set setName(String name) => this.name = name;

  List<Option> get getOptions => options!;

  set setOptions(List<Option> options) => this.options = options;

  String get getLabel => label!;

  set setLabel(String label) => this.label = label;
}
