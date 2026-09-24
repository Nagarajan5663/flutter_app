class VendorCreditModel {
  final String? id;
  final String creditNoteNumber; // Vendor Credit Note #
  final String vendorId;
  final String vendorName;
  final DateTime date;
  final double amount;
  final String reason; // Optional
  final double amountUsed; // applied against bills so far

  VendorCreditModel({
    this.id,
    required this.creditNoteNumber,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.amount,
    this.reason = '',
    this.amountUsed = 0,
  });

  double get amountRemaining => (amount - amountUsed) < 0 ? 0 : (amount - amountUsed);

  String get status => amountRemaining <= 0 ? 'Closed' : 'Open';

  VendorCreditModel copyWith({String? id, double? amountUsed}) {
    return VendorCreditModel(
      id: id ?? this.id,
      creditNoteNumber: creditNoteNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      date: date,
      amount: amount,
      reason: reason,
      amountUsed: amountUsed ?? this.amountUsed,
    );
  }

  factory VendorCreditModel.fromJson(Map<String, dynamic> json) {
    return VendorCreditModel(
      id: json['id']?.toString(),
      creditNoteNumber: json['creditNoteNumber']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      reason: json['reason']?.toString() ?? '',
      amountUsed: double.tryParse(json['amountUsed']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'creditNoteNumber': creditNoteNumber,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'date': date.toIso8601String(),
        'amount': amount,
        'reason': reason,
        'amountUsed': amountUsed,
      };
}