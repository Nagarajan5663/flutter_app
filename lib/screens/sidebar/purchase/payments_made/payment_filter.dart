import 'payment_model.dart';

class PaymentFilter {
  final String vendorName;
  final String billNumber;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const PaymentFilter({
    this.vendorName = '',
    this.billNumber = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(PaymentModel payment) {
    final matchesVendor = vendorName.trim().isEmpty ||
        payment.vendorName.toLowerCase().contains(vendorName.trim().toLowerCase());

    final matchesBill = billNumber.trim().isEmpty ||
        payment.billNumber.toLowerCase().contains(billNumber.trim().toLowerCase());

    final matchesFrom = dateFrom == null ||
        !payment.paymentDate.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));

    final matchesTo = dateTo == null ||
        !payment.paymentDate
            .isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));

    return matchesVendor && matchesBill && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (vendorName.trim().isNotEmpty) params['vendor_filter'] = vendorName.trim();
    if (billNumber.trim().isNotEmpty) params['bill_filter'] = billNumber.trim();
    if (dateFrom != null) params['date_from'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['date_to'] = dateTo!.toIso8601String();
    return params;
  }
}