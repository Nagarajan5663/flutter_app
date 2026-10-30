import '../sales_line_item_model.dart';

class SalesOrderModel {
  final String? id;
  final String soNumber;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final List<SalesLineItemModel> items;
  final String approvalStatus;

  SalesOrderModel({
    this.id,
    required this.soNumber,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.items,
    this.approvalStatus = 'Pending',
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id']?.toString(),
      soNumber: (json['soNumber'] ?? json['orderNumber'])?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      orderDate: DateTime.tryParse((json['orderDate'] ?? json['date'])?.toString() ?? '') ?? DateTime.now(),
      approvalStatus: json['approvalStatus']?.toString() ?? 'Pending',
      items: (json['items'] as List? ?? [])
          .map((item) => SalesLineItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
