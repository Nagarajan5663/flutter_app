class PaymentMadeModel {
  const PaymentMadeModel({
    required this.id,
    required this.paymentNumber,
    required this.billId,
    required this.billNumber,
    required this.vendorName,
    required this.vendorInvoiceNumber,
    required this.date,
    required this.amount,
    required this.mode,
    this.reference = '',
    this.paidBy = '',
    this.notes = '',
    this.vendorEmail = '',
    this.vendorPhone = '',
  });

  final String id;
  final String paymentNumber;
  final String billId;
  final String billNumber;
  final String vendorName;
  final String vendorInvoiceNumber;
  final DateTime date;
  final double amount;
  final String mode;
  final String reference;
  final String paidBy;
  final String notes;
  final String vendorEmail;
  final String vendorPhone;

  factory PaymentMadeModel.fromJson(Map<String, dynamic> json) {
    return PaymentMadeModel(
      id: json['id']?.toString() ?? '',
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      billId: json['billId']?.toString() ?? '',
      billNumber: json['billNumber']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      vendorInvoiceNumber: json['vendorInvoiceNumber']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      mode: json['mode']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      paidBy: json['paidBy']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      vendorEmail: json['vendorEmail']?.toString() ?? '',
      vendorPhone: json['vendorPhone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'paymentNumber': paymentNumber,
        'billId': billId,
        'billNumber': billNumber,
        'vendorName': vendorName,
        'vendorInvoiceNumber': vendorInvoiceNumber,
        'date': date.toIso8601String(),
        'amount': amount,
        'mode': mode,
        'reference': reference,
        'paidBy': paidBy,
        'notes': notes,
      };
}
