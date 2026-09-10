class PaymentReceivedModel {
  final String? id;
  final String paymentNumber;
  final String customerId;
  final String customerName;
  final String invoiceId;
  final String invoiceNumber;
  final DateTime paymentDate;
  final double amountReceived;
  final String paymentMode;
  final String utrReference;
  final String remarks;

  PaymentReceivedModel({
    this.id,
    required this.paymentNumber,
    required this.customerId,
    required this.customerName,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.paymentDate,
    required this.amountReceived,
    required this.paymentMode,
    this.utrReference = '',
    this.remarks = '',
  });

  PaymentReceivedModel copyWith({String? id}) {
    return PaymentReceivedModel(
      id: id ?? this.id,
      paymentNumber: paymentNumber,
      customerId: customerId,
      customerName: customerName,
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      paymentDate: paymentDate,
      amountReceived: amountReceived,
      paymentMode: paymentMode,
      utrReference: utrReference,
      remarks: remarks,
    );
  }

  factory PaymentReceivedModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceivedModel(
      id: json['id']?.toString(),
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      paymentDate: DateTime.tryParse(json['paymentDate']?.toString() ?? '') ?? DateTime.now(),
      amountReceived: double.tryParse(json['amountReceived']?.toString() ?? '') ?? 0,
      paymentMode: json['paymentMode']?.toString() ?? 'Bank Transfer',
      utrReference: json['utrReference']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'paymentNumber': paymentNumber,
        'customerId': customerId,
        'customerName': customerName,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'paymentDate': paymentDate.toIso8601String(),
        'amountReceived': amountReceived,
        'paymentMode': paymentMode,
        'utrReference': utrReference,
        'remarks': remarks,
      };
}