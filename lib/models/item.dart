class Item {
  final String orderNr;
  final String itemNumber;
  final String itemDescription;

  Item({required this.orderNr, required this.itemNumber, required this.itemDescription});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        orderNr: json['OrderNr'].toString(), // Convert to string
      itemNumber: json['ItemNumber'].toString(), // Convert to string
      itemDescription: json['ItemDescription'].toString(),
    );
  }
}
