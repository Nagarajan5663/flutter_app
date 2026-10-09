import 'delivery_challan_model.dart';

class DeliveryChallanFilter {
  final String customerName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const DeliveryChallanFilter({
    this.customerName = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(DeliveryChallanModel challan) {
    final matchesCustomer = customerName.trim().isEmpty ||
        challan.customerName.toLowerCase().contains(customerName.trim().toLowerCase());
    final matchesFrom = dateFrom == null ||
        !challan.challanDate.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));
    final matchesTo = dateTo == null ||
        !challan.challanDate.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));
    return matchesCustomer && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() => {
        if (customerName.trim().isNotEmpty) 'customer': customerName.trim(),
        if (dateFrom != null) 'dateFrom': _date(dateFrom!),
        if (dateTo != null) 'dateTo': _date(dateTo!),
      };

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
