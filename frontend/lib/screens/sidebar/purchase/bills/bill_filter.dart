import 'bill_model.dart';

class BillFilter {
  final String status; // 'All' | 'Unpaid' | 'Partially Paid' | 'Paid'
  final String vendorName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const BillFilter({
    this.status = 'All',
    this.vendorName = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(BillModel bill) {
    final matchesStatus = status == 'All' || bill.status == status;

    final matchesVendor = vendorName.trim().isEmpty ||
        bill.vendorName.toLowerCase().contains(vendorName.trim().toLowerCase());

    final matchesFrom = dateFrom == null ||
        !bill.billDate.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));

    final matchesTo = dateTo == null ||
        !bill.billDate.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));

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