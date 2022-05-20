// ignore_for_file: unnecessary_this

class Product {
  String id = "";
  String type = "";
  String name = "";
  String description = "";
  String price = "";
  String regularPrice = "";
  String productType = "";
  String categories = "[]";
  String image = "";
  String inWishList = "";
  String stockStatus = "";
  String lowestPrice = "0";
  String highestPrice = "0";
  List<Map<String, dynamic>> attributes = [];
  List<Map<String, dynamic>> variations = [];

  Product({this.id = "", this.name = ""});

  String get getID => this.id;

  set setID(String id) => this.id = id;

  String get getType => this.type;

  set setType(String type) => this.type = type;

  String get getName => this.name;

  set setName(String name) => this.name = name;

  String get getDescription => this.description;

  set setDescription(String description) => this.description = description;

  String get getPrice => this.price;

  set setPrice(String price) => this.price = price;

  String get getRegularPrice => this.regularPrice;

  set setRegularPrice(String regularPrice) => this.regularPrice = regularPrice;

  String get getProductType => this.productType;

  set setProductType(String productType) => this.productType = productType;

  String get getCategories => this.categories;

  set setCategories(String categories) => this.categories = categories;

  String get getImage => this.image;

  set setImage(String image) => this.image = image;

  String get getInWishList => this.inWishList;

  set setInWishList(String inWishList) => this.inWishList = inWishList;

  String get getStockStatus => this.stockStatus;

  set setStockStatus(String stockStatus) => this.stockStatus = stockStatus;

  String get getLowestPrice => this.lowestPrice;

  set setLowestPrice(String lowestPrice) => this.lowestPrice = lowestPrice;

  String get getHighestPrice => this.highestPrice;

  set setHighestPrice(String highestPrice) => this.highestPrice = highestPrice;

  List<Map<String, dynamic>> get getAttributes => this.attributes;

  set setAttributes(List<Map<String, dynamic>> attributes) =>
      this.attributes = attributes;

  List<Map<String, dynamic>> get getVariations => this.variations;

  set setVariations(List<Map<String, dynamic>> variations) =>
      this.variations = variations;
}
