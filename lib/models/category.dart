// ignore_for_file: non_constant_identifier_names

class Category {
  String? name;
  String? count;
  String? sub_cats;
  String? image;
  String? icon;
  String? slug;

  Category(
      {this.name, this.count, this.sub_cats, this.image, this.icon, this.slug});

  String get getName => name!;

  set setName(String name) => this.name = name;

  String get getCount => count!;

  set setCount(String count) => this.count = count;

  String get subcats => sub_cats!;

  set subcats(String value) => sub_cats = value;

  String get getImage => image!;

  set setImage(String image) => this.image = image;

  String get getIcon => icon!;

  set setIcon(String icon) => this.icon = icon;

  String get getSlug => slug!;

  set setSlug(String slug) => this.slug = slug;
}
