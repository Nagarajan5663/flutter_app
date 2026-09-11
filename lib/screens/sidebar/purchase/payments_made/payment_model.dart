class PaymentModel {
  final String? id;
  final String paymentNumber; // Payment #
  final String billId;
  final String billNumber;
  final String vendorId;
  final String vendorName;
  final double amountDue; // bill's amount due at the time this payment was recorded
  final DateTime paymentDate;
  final double amountPaid;
  final String paymentMode; // Bank Transfer, Cash, Cheque, Credit Card, UPI, Other
  final String referenceNumber;

  PaymentModel({
    this.id,
    required this.paymentNumber,
    required this.billId,
    required this.billNumber,
    required this.vendorId,
    required this.vendorName,
    this.amountDue = 0,
    required this.paymentDate,
    required this.amountPaid,
    this.paymentMode = 'Bank Transfer',
    this.referenceNumber = '',
  });

  PaymentModel copyWith({String? id}) {
    return PaymentModel(
      id: id ?? this.id,
      paymentNumber: paymentNumber,
      billId: billId,
      billNumber: billNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      amountDue: amountDue,
      paymentDate: paymentDate,
      amountPaid: amountPaid,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString(),
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      billId: json['billId']?.toString() ?? '',
      billNumber: json['billNumber']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      amountDue: double.tryParse(json['amountDue'].toString()) ?? 0,
      paymentDate:
          DateTime.tryParse(json['paymentDate']?.toString() ?? '') ?? DateTime.now(),
      amountPaid: double.tryParse(json['amountPaid'].toString()) ?? 0,
      paymentMode: json['paymentMode']?.toString() ?? 'Bank Transfer',
      referenceNumber: json['referenceNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'paymentNumber': paymentNumber,
        'billId': billId,
        'billNumber': billNumber,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'amountDue': amountDue,
        'paymentDate': paymentDate.toIso8601String(),
        'amountPaid': amountPaid,
        'paymentMode': paymentMode,
        'referenceNumber': referenceNumber,
      };
}