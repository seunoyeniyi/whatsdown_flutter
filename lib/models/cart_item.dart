class CartItem {
  String? id;
  String? name;
  String? price;
  String? quantity;
  String? image;
  String? productType;

  CartItem(
      {this.id,
      this.name,
      this.image,
      this.quantity,
      this.price,
      this.productType});

  String get getID => id!;

  set setID(String id) => this.id = id;

  String get getName => name!;

  set setName(String name) => this.name = name;

  String get getProductType => productType!;

  set setProductType(String type) => productType = type;

  String get getPrice => price!;

  set setPrice(String price) => this.price = price;

  String get getQuantity => quantity!;

  set setQuantity(String quantity) => this.quantity = quantity;

  String get getImage => image!;

  set setImage(String image) => this.image = image;
}
