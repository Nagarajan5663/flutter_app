class PartModel {
  final int? id;
  final String name;
  final String sku;
  final String purchasePrice;
  final String description;

  const PartModel({
    this.id,
    required this.name,
    required this.sku,
    required this.purchasePrice,
    required this.description,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['id'] == null
          ? null
          : int.tryParse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      purchasePrice:
          json['purchase_price']?.toString() ?? '0.00',
      description:
          json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'purchase_price': purchasePrice,
      'description':
          description.isEmpty ? null : description,
    };
  }

  PartModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? purchasePrice,
    String? description,
  }) {
    return PartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      purchasePrice:
          purchasePrice ?? this.purchasePrice,
      description:
          description ?? this.description,
    );
  }
}