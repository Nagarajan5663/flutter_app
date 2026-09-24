import 'purchase_order_model.dart';

class PurchaseOrderFilter {
  final String status; // 'All' | 'Draft' | 'Ordered' | 'Received' | 'Cancelled'
  final String vendorName;
  final String referenceNumber;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const PurchaseOrderFilter({
    this.status = 'All',
    this.vendorName = '',
    this.referenceNumber = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(PurchaseOrderModel po) {
    final matchesStatus = status == 'All' || po.status == status;

    final matchesVendor = vendorName.trim().isEmpty ||
        po.vendorName.toLowerCase().contains(vendorName.trim().toLowerCase());

    final matchesRef = referenceNumber.trim().isEmpty ||
        po.referenceNumber.toLowerCase().contains(referenceNumber.trim().toLowerCase());

    final matchesFrom = dateFrom == null ||
        !po.date.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));

    final matchesTo = dateTo == null ||
        !po.date.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));

    return matchesStatus && matchesVendor && matchesRef && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (status != 'All') params['status_filter'] = status;
    if (vendorName.trim().isNotEmpty) params['vendor_filter'] = vendorName.trim();
    if (referenceNumber.trim().isNotEmpty) params['reference_filter'] = referenceNumber.trim();
    if (dateFrom != null) params['date_from'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['date_to'] = dateTo!.toIso8601String();
    return params;
  }
}