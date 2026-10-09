import '../sales_line_item_model.dart';

class InvoiceModel {
  final String? id;
  final String invoiceNumber;
  final String? soId;
  final String? soNumber;
  final String? estimateNumber;
  final String? deliveryChallanNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final DateTime? dueDate;
  final String creditTerms;
  final List<SalesLineItemModel> items;
  final double tax;
  final double amountPaid;
  final String approvalStatus;
  final String documentStatus;
  final String notes;
  final String termsAndConditions;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    this.soId,
    this.soNumber,
    this.estimateNumber,
    this.deliveryChallanNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone = '',
    required this.date,
    this.dueDate,
    this.creditTerms = 'Immediate Payment',
    required this.items,
    this.tax = 0,
    this.amountPaid = 0,
    this.approvalStatus = 'Pending',
    this.documentStatus = 'Draft',
    this.notes = '',
    this.termsAndConditions = '',
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
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber,
      soId: soId,
      soNumber: soNumber,
      estimateNumber: estimateNumber,
      deliveryChallanNumber: deliveryChallanNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      date: date,
      dueDate: dueDate,
      creditTerms: creditTerms,
      items: items,
      tax: tax,
      amountPaid: amountPaid ?? this.amountPaid,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      documentStatus: documentStatus ?? this.documentStatus,
      notes: notes,
      termsAndConditions: termsAndConditions,
    );
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      soId: json['soId']?.toString(),
      soNumber: json['soNumber']?.toString(),
      estimateNumber: json['estimateNumber']?.toString(),
      deliveryChallanNumber: json['deliveryChallanNumber']?.toString(),
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      creditTerms: json['creditTerms']?.toString() ?? 'Immediate Payment',
      items: (json['items'] as List? ?? [])
          .map((e) => SalesLineItemModel.fromJson(e))
          .toList(),
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0,
      amountPaid: double.tryParse(json['amountPaid']?.toString() ?? '') ?? 0,
      approvalStatus: json['approvalStatus']?.toString() ?? 'Pending',
      documentStatus: json['documentStatus']?.toString() ?? 'Draft',
      notes: json['notes']?.toString() ?? '',
      termsAndConditions: json['termsAndConditions']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'invoiceNumber': invoiceNumber,
        'soId': soId,
        'soNumber': soNumber,
        'estimateNumber': estimateNumber,
        'deliveryChallanNumber': deliveryChallanNumber,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'creditTerms': creditTerms,
        'items': items.map((e) => e.toJson()).toList(),
        'tax': tax,
        'amountPaid': amountPaid,
        'approvalStatus': approvalStatus,
        'documentStatus': documentStatus,
        'notes': notes,
        'termsAndConditions': termsAndConditions,
      };
}
