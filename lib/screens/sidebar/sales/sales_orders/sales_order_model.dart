import '../sales_line_item_model.dart';

class SalesOrderModel {
  final String? id;
  final String soNumber;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final List<SalesLineItemModel> items;

  SalesOrderModel({
    this.id,
    required this.soNumber,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.items,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id']?.toString(),
      soNumber: json['soNumber']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      orderDate: DateTime.tryParse(json['orderDate']?.toString() ?? '') ?? DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((item) => SalesLineItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
