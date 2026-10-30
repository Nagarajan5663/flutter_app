import '../sales_line_item_model.dart';

class DeliveryChallanModel {
  final String? id;
  final String challanNumber;
  final String customerId;
  final String customerName;
  final String? invoiceId;
  final String? invoiceNumber;
  final String? salesOrderId;
  final String? salesOrderNumber;
  final String? estimateId;
  final String? estimateNumber;
  final DateTime challanDate;
  final DateTime? deliveryDate;
  final String transportationDetails;
  final String notes;
  final List<SalesLineItemModel> items;
  final String status; // Draft, Shipped, Delivered, Void

  DeliveryChallanModel({
    this.id,
    required this.challanNumber,
    required this.customerId,
    required this.customerName,
    this.invoiceId,
    this.invoiceNumber,
    this.salesOrderId,
    this.salesOrderNumber,
    this.estimateId,
    this.estimateNumber,
    required this.challanDate,
    this.deliveryDate,
    this.transportationDetails = '',
    this.notes = '',
    required this.items,
    this.status = 'Draft',
  });

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get total => subTotal;

  DeliveryChallanModel copyWith({String? id, String? status}) {
    return DeliveryChallanModel(
      id: id ?? this.id,
      challanNumber: challanNumber,
      customerId: customerId,
      customerName: customerName,
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      salesOrderId: salesOrderId,
      salesOrderNumber: salesOrderNumber,
      estimateId: estimateId,
      estimateNumber: estimateNumber,
      challanDate: challanDate,
      deliveryDate: deliveryDate,
      transportationDetails: transportationDetails,
      notes: notes,
      items: items,
      status: status ?? this.status,
    );
  }

  factory DeliveryChallanModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanModel(
      id: json['id']?.toString(),
      challanNumber: json['challanNumber']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      salesOrderId: json['salesOrderId']?.toString(),
      salesOrderNumber: json['salesOrderNumber']?.toString(),
      estimateId: json['estimateId']?.toString(),
      estimateNumber: json['estimateNumber']?.toString(),
      challanDate: DateTime.tryParse(json['challanDate']?.toString() ?? '') ??
          DateTime.now(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'].toString())
          : null,
      transportationDetails: json['transportationDetails']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => SalesLineItemModel.fromJson(e))
          .toList(),
      status: json['status']?.toString() ?? 'Draft',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'challanNumber': challanNumber,
        'customerId': customerId,
        'customerName': customerName,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'salesOrderId': salesOrderId,
        'salesOrderNumber': salesOrderNumber,
        'estimateId': estimateId,
        'estimateNumber': estimateNumber,
        'challanDate': challanDate.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'transportationDetails': transportationDetails,
        'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status,
      };
}
