class Order {
  String id;
  String date;
  String status;
  String paymentMethod;
  String amount;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.paymentMethod,
    required this.amount,
  });

  String get getId => id;

  set setId(String id) => this.id = id;

  String get getDate => date;

  set setDate(String date) => this.date = date;

  String get getStatus => status;

  set setStatus(String status) => status = status;

  String get getPaymentMethod => paymentMethod;

  set setPaymentMethod(String paymentMethod) =>
      this.paymentMethod = paymentMethod;

  String get getAmount => amount;

  set setAmount(String amount) => this.amount = amount;
}
