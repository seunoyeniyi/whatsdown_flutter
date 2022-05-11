class AttributeTerm {
  String? name;
  String? taxonomy;
  String? slug;

  AttributeTerm({this.name, this.taxonomy, this.slug});

  String get getName => name!;

  set setName(String name) => this.name = name;

  String get getTaxonomy => taxonomy!;

  set setTaxonomy(String taxonomy) => this.taxonomy = taxonomy;

  String get getSlug => slug!;

  set setSlug(String slug) => this.slug = slug;
}
