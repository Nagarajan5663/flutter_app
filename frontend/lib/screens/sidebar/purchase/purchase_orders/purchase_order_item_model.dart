class PurchaseOrderItemModel {
  final String itemName;
  final String description;
  final double qty;
  final double rate;

  PurchaseOrderItemModel({
    required this.itemName,
    required this.description,
    required this.qty,
    required this.rate,
  });

  double get amount => qty * rate;

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemModel(
      itemName: json['itemName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      qty: double.tryParse(json['qty'].toString()) ?? 0,
      rate: double.tryParse(json['rate'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'description': description,
        'qty': qty,
        'rate': rate,
      };
}