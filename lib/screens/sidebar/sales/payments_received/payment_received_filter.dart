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
}