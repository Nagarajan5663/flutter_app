class SalesLineItemModel {
  final String? itemId;
  final String? partId;
  final String sourceType;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double amount;

  SalesLineItemModel({
    this.itemId,
    this.partId,
    this.sourceType = 'Item',
    required this.itemName,
    this.description = '',
    required this.quantity,
    required this.rate,
    double? amount,
  }) : amount = amount ?? quantity * rate;

  SalesLineItemModel copyWith({
    String? itemId,
    String? partId,
    String? sourceType,
    String? itemName,
    String? description,
    double? quantity,
    double? rate,
    double? amount,
  }) {
    return SalesLineItemModel(
      itemId: itemId ?? this.itemId,
      partId: partId ?? this.partId,
      sourceType: sourceType ?? this.sourceType,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  factory SalesLineItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = double.tryParse((json['quantity'] ?? json['qty'])?.toString() ?? '') ?? 0;
    final rate = double.tryParse(json['rate']?.toString() ?? '') ?? 0;
    return SalesLineItemModel(
      itemId: json['itemId']?.toString(),
      partId: json['partId']?.toString(),
      sourceType: json['sourceType']?.toString() ?? 'Item',
      itemName: json['itemName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantity: quantity,
      rate: rate,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? quantity * rate,
    );
  }

  Map<String, dynamic> toJson() => {
        if (itemId != null) 'itemId': itemId,
        if (partId != null) 'partId': partId,
        'sourceType': sourceType,
        'itemName': itemName,
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
      };
}
