import 'invoice_model.dart';

class InvoiceFilter {
  final String status;
  final String customerName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const InvoiceFilter({
    this.status = 'All',
    this.customerName = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(InvoiceModel invoice) {
    final matchesStatus =
        status == 'All' ||
        invoice.status == status ||
        invoice.documentStatus == status;
    final matchesCustomer = customerName.trim().isEmpty ||
        invoice.customerName.toLowerCase().contains(customerName.trim().toLowerCase());
    final matchesFrom = dateFrom == null ||
        !invoice.date.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));
    final matchesTo = dateTo == null ||
        !invoice.date.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));
    return matchesStatus && matchesCustomer && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() => {
        if (status != 'All') 'status': status,
        if (customerName.trim().isNotEmpty) 'customer': customerName.trim(),
        if (dateFrom != null) 'dateFrom': _date(dateFrom!),
        if (dateTo != null) 'dateTo': _date(dateTo!),
      };

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
