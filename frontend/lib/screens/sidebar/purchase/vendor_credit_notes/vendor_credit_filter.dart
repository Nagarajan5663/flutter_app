import 'vendor_credit_model.dart';

class VendorCreditFilter {
  final String status; // 'All' | 'Open' | 'Closed'
  final String vendorName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const VendorCreditFilter({
    this.status = 'All',
    this.vendorName = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(VendorCreditModel credit) {
    final matchesStatus = status == 'All' || credit.status == status;

    final matchesVendor = vendorName.trim().isEmpty ||
        credit.vendorName.toLowerCase().contains(vendorName.trim().toLowerCase());

    final matchesFrom = dateFrom == null ||
        !credit.date.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));

    final matchesTo = dateTo == null ||
        !credit.date.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));

    return matchesStatus && matchesVendor && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (status != 'All') params['status_filter'] = status;
    if (vendorName.trim().isNotEmpty) params['vendor_filter'] = vendorName.trim();
    if (dateFrom != null) params['date_from'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['date_to'] = dateTo!.toIso8601String();
    return params;
  }
}