import 'payment_received_model.dart';

class PaymentReceivedFilter {
  final String customerName;
  final String invoiceNumber;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const PaymentReceivedFilter({
    this.customerName = '',
    this.invoiceNumber = '',
    this.dateFrom,
    this.dateTo,
  });

  bool matches(PaymentReceivedModel payment) {
    final matchesCustomer = customerName.trim().isEmpty ||
        payment.customerName.toLowerCase().contains(customerName.trim().toLowerCase());
    final matchesInvoice = invoiceNumber.trim().isEmpty ||
        payment.invoiceNumber.toLowerCase().contains(invoiceNumber.trim().toLowerCase());
    final matchesFrom = dateFrom == null ||
        !payment.paymentDate.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day));
    final matchesTo = dateTo == null ||
        !payment.paymentDate.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59));
    return matchesCustomer && matchesInvoice && matchesFrom && matchesTo;
  }

  Map<String, String> toQueryParams() {
    final query = <String, String>{};
    if (customerName.trim().isNotEmpty) {
      query['customer'] = customerName.trim();
    }
    if (invoiceNumber.trim().isNotEmpty) {
      query['invoice'] = invoiceNumber.trim();
    }
    if (dateFrom != null) {
      query['dateFrom'] = _formatDate(dateFrom!);
    }
    if (dateTo != null) {
      query['dateTo'] = _formatDate(dateTo!);
    }
    return query;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}