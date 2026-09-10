import 'purchase_order_item_model.dart';

class PurchaseOrderModel {
  final String? id;
  final String poNumber;
  final String vendorId;
  final String vendorName;
  final DateTime date;
  final DateTime? deliveryExpectedDate;
  final String paymentTerms;
  final DateTime? dueDate;
  final String referenceNumber;
  final List<PurchaseOrderItemModel> items;
  final String status; // Draft, Ordered, Received, Cancelled

  PurchaseOrderModel({
    this.id,
    required this.poNumber,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    this.deliveryExpectedDate,
    required this.paymentTerms,
    this.dueDate,
    this.referenceNumber = '',
    required this.items,
    this.status = 'Draft',
  });

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get total => subTotal;

  PurchaseOrderModel copyWith({String? id, String? status}) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      poNumber: poNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      date: date,
      deliveryExpectedDate: deliveryExpectedDate,
      paymentTerms: paymentTerms,
      dueDate: dueDate,
      referenceNumber: referenceNumber,
      items: items,
      status: status ?? this.status,
    );
  }

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id']?.toString(),
      poNumber: json['poNumber']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      deliveryExpectedDate: json['deliveryExpectedDate'] != null
          ? DateTime.tryParse(json['deliveryExpectedDate'].toString())
          : null,
      paymentTerms: json['paymentTerms']?.toString() ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      referenceNumber: json['referenceNumber']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseOrderItemModel.fromJson(e))
          .toList(),
      status: json['status']?.toString() ?? 'Draft',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'poNumber': poNumber,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'date': date.toIso8601String(),
        'deliveryExpectedDate': deliveryExpectedDate?.toIso8601String(),
        'paymentTerms': paymentTerms,
        'dueDate': dueDate?.toIso8601String(),
        'referenceNumber': referenceNumber,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status,
      };
}