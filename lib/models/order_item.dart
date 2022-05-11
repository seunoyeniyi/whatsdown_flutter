class OrderItem {
  String name;
  String quantity;
  String amount;

  OrderItem({required this.name, required this.quantity, required this.amount});

  String get getName => name;

  set setName(String name) => this.name = name;

  String get getQuantity => quantity;

  set setQuantity(String quantity) => this.quantity = quantity;

  String get getAmount => amount;

  set setAmount(String amount) => this.amount = amount;
}
