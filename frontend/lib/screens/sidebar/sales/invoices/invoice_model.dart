import '../sales_line_item_model.dart';

class InvoiceModel {
  final String? id;
  final String invoiceNumber;
  final String? soId;
  final String? soNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime date;
  final DateTime? dueDate;
  final String creditTerms;
  final List<SalesLineItemModel> items;
  final double tax;
  final double amountPaid;
  final String approvalStatus;
  final String documentStatus;
  final DateTime? approvedAt;
  final int? approvedBy;
  final String? estimateId;
  final String? estimateNumber;
  final String notes;
  final String termsAndConditions;
  final String? deliveryChallanId;
  final String? deliveryChallanNumber;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    this.soId,
    this.soNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail = '',
    this.customerPhone = '',
    required this.date,
    this.dueDate,
    this.creditTerms = 'Immediate Payment',
    required this.items,
    this.tax = 0,
    this.amountPaid = 0,
    this.approvalStatus = 'Pending',
    this.documentStatus = 'Draft',
    this.approvedAt,
    this.approvedBy,
    this.estimateId,
    this.estimateNumber,
    this.notes = '',
    this.termsAndConditions = '',
    this.deliveryChallanId,
    this.deliveryChallanNumber,
  });

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get total => subTotal + tax;
  double get amountDue => (total - amountPaid) < 0 ? 0 : (total - amountPaid);

  String get status {
    if (amountPaid <= 0) return 'Unpaid';
    if (amountPaid >= total) return 'Paid';
    return 'Partially Paid';
  }

  InvoiceModel copyWith({
    String? id,
    double? amountPaid,
    String? approvalStatus,
    String? documentStatus,
    DateTime? approvedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber,
      soId: soId,
      soNumber: soNumber,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      date: date,
      dueDate: dueDate,
      creditTerms: creditTerms,
      items: items,
      tax: tax,
      amountPaid: amountPaid ?? this.amountPaid,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      documentStatus: documentStatus ?? this.documentStatus,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy,
      estimateId: estimateId,
      estimateNumber: estimateNumber,
      notes: notes,
      termsAndConditions: termsAndConditions,
      deliveryChallanId: deliveryChallanId,
      deliveryChallanNumber: deliveryChallanNumber,
    );
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      soId: json['soId']?.toString(),
      soNumber: json['soNumber']?.toString(),
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      creditTerms: json['creditTerms']?.toString() ?? 'Immediate Payment',
      items: (json['items'] as List? ?? []).map((e) => SalesLineItemModel.fromJson(e)).toList(),
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0,
      amountPaid: double.tryParse(json['amountPaid']?.toString() ?? '') ?? 0,
      approvalStatus: json['approvalStatus']?.toString() ?? 'Pending',
      documentStatus: json['documentStatus']?.toString() ?? 'Draft',
      approvedAt: json['approvedAt'] == null ? null : DateTime.tryParse(json['approvedAt'].toString()),
      approvedBy: json['approvedBy'] == null ? null : int.tryParse(json['approvedBy'].toString()),
      estimateId: json['estimateId']?.toString(),
      estimateNumber: json['estimateNumber']?.toString(),
      notes: json['notes']?.toString() ?? '',
      termsAndConditions: json['termsAndConditions']?.toString() ?? '',
      deliveryChallanId: json['deliveryChallanId']?.toString(),
      deliveryChallanNumber: json['deliveryChallanNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'invoiceNumber': invoiceNumber,
        'soId': soId,
        'soNumber': soNumber,
        'customerId': customerId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'creditTerms': creditTerms,
        'items': items.map((e) => e.toJson()).toList(),
        'tax': tax,
        'amountPaid': amountPaid,
        'approvalStatus': approvalStatus,
        'documentStatus': documentStatus,
        'estimateId': estimateId,
        'estimateNumber': estimateNumber,
        'notes': notes,
        'termsAndConditions': termsAndConditions,
      };
}
