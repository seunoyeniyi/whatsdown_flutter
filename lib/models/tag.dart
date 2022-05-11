class Tag {
  String? name;
  String? slug;

  Tag({this.name, this.slug});

  String get getName => name!;

  set setName(String name) => this.name = name;

  String get getSlug => slug!;

  set setSlug(String slug) => this.slug = slug;
}
