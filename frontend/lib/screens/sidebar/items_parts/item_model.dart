class ItemModel {
  final int? id;
  final String name;
  final String sku;
  final String purchasePrice;
  final String salesPrice;
  final String tax;
  final String description;

  const ItemModel({
    this.id,
    required this.name,
    required this.sku,
    required this.purchasePrice,
    required this.salesPrice,
    required this.tax,
    required this.description,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] == null
          ? null
          : int.tryParse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      purchasePrice:
          json['purchase_price']?.toString() ?? '0.00',
      salesPrice:
          json['sales_price']?.toString() ?? '0.00',
      tax: json['tax']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'purchase_price': purchasePrice,
      'sales_price': salesPrice,
      'tax': tax.isEmpty ? null : tax,
      'description':
          description.isEmpty ? null : description,
    };
  }

  ItemModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? purchasePrice,
    String? salesPrice,
    String? tax,
    String? description,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      purchasePrice:
          purchasePrice ?? this.purchasePrice,
      salesPrice: salesPrice ?? this.salesPrice,
      tax: tax ?? this.tax,
      description:
          description ?? this.description,
    );
  }
}