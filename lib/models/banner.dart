class Banner {
  String image;
  String title;
  String description;
  String onClickTo;
  String category;
  String url;

  Banner(
      {required this.image,
      required this.title,
      required this.description,
      required this.onClickTo,
      required this.category,
      required this.url});

  String get getImage => image;

  set setImage(String image) => this.image = image;

  String get getTitle => title;

  set setTitle(String title) => this.title = title;

  String get getDescription => description;

  set setDescription(String description) => this.description = description;

  String get getOnClickTo => onClickTo;

  set setOnClickTo(String onClickTo) => this.onClickTo = onClickTo;

  String get getCategory => category;

  set setCategory(String category) => this.category = category;

  String get getUrl => url;

  set setUrl(String url) => this.url = url;
}
