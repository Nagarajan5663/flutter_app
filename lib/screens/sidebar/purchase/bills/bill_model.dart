import '../purchase_orders/purchase_order_item_model.dart';

class BillModel {
  final String? id;
  final String billNumber;
  final String vendorInvoiceNumber;
  final String? invoiceAttachmentPath;
  final String vendorId;
  final String vendorName;
  final String? purchaseOrderId;
  final String? purchaseOrderNumber;
  final DateTime billDate;
  final DateTime? dueDate;
  final List<PurchaseOrderItemModel> items;
  final double taxAmount;
  final double amountPaid;

  BillModel({
    this.id,
    required this.billNumber,
    this.vendorInvoiceNumber = '',
    this.invoiceAttachmentPath,
    required this.vendorId,
    required this.vendorName,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    required this.billDate,
    this.dueDate,
    required this.items,
    this.taxAmount = 0,
    this.amountPaid = 0,
  });

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get total => subTotal + taxAmount;
  double get amountDue => (total - amountPaid) < 0 ? 0 : (total - amountPaid);

  String get status {
    if (amountPaid <= 0) return 'Unpaid';
    if (amountPaid >= total) return 'Paid';
    return 'Partially Paid';
  }

  BillModel copyWith({String? id, double? amountPaid}) {
    return BillModel(
      id: id ?? this.id,
      billNumber: billNumber,
      vendorInvoiceNumber: vendorInvoiceNumber,
      invoiceAttachmentPath: invoiceAttachmentPath,
      vendorId: vendorId,
      vendorName: vendorName,
      purchaseOrderId: purchaseOrderId,
      purchaseOrderNumber: purchaseOrderNumber,
      billDate: billDate,
      dueDate: dueDate,
      items: items,
      taxAmount: taxAmount,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id']?.toString(),
      billNumber: json['billNumber']?.toString() ?? '',
      vendorInvoiceNumber: json['vendorInvoiceNumber']?.toString() ?? '',
      invoiceAttachmentPath: json['invoiceAttachmentPath']?.toString(),
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      purchaseOrderId: json['purchaseOrderId']?.toString(),
      purchaseOrderNumber: json['purchaseOrderNumber']?.toString(),
      billDate: DateTime.tryParse(json['billDate']?.toString() ?? '') ?? DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseOrderItemModel.fromJson(e))
          .toList(),
      taxAmount: double.tryParse(json['taxAmount']?.toString() ?? '') ?? 0,
      amountPaid: double.tryParse(json['amountPaid']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'billNumber': billNumber,
        'vendorInvoiceNumber': vendorInvoiceNumber,
        'invoiceAttachmentPath': invoiceAttachmentPath,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'purchaseOrderId': purchaseOrderId,
        'purchaseOrderNumber': purchaseOrderNumber,
        'billDate': billDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'taxAmount': taxAmount,
        'amountPaid': amountPaid,
      };
}