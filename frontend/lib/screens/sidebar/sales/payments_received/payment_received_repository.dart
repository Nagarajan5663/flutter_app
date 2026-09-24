import '../invoices/invoice_repository.dart';
import 'payment_received_filter.dart';
import 'payment_received_model.dart';

abstract class PaymentReceivedRepository {
  Future<List<PaymentReceivedModel>> getPayments({PaymentReceivedFilter? filter});
  Future<PaymentReceivedModel> addPayment(PaymentReceivedModel payment);
  Future<void> deletePayment(String id);
  Future<String> nextPaymentNumber();
}

/// Recording a payment also updates the linked invoice's amountPaid,
/// via InvoiceRepository's existing recordPayment method — same pattern
/// as PurchaseOrder/Bill on the Purchase side.
class InMemoryPaymentReceivedRepository implements PaymentReceivedRepository {
  InMemoryPaymentReceivedRepository._internal();
  static final InMemoryPaymentReceivedRepository instance =
      InMemoryPaymentReceivedRepository._internal();
  factory InMemoryPaymentReceivedRepository() => instance;

  final InvoiceRepository _invoiceRepository = InMemoryInvoiceRepository();
  final List<PaymentReceivedModel> _payments = [];
  int _nextId = 1;

  @override
  Future<List<PaymentReceivedModel>> getPayments({PaymentReceivedFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<PaymentReceivedModel>.from(_payments);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<PaymentReceivedModel> addPayment(PaymentReceivedModel payment) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = payment.copyWith(id: (_nextId++).toString());
    _payments.add(withId);
    await _invoiceRepository.recordPayment(payment.invoiceId, payment.amountReceived);
    return withId;
  }

  @override
  Future<void> deletePayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _payments.removeWhere((p) => p.id == id);
  }

  @override
  Future<String> nextPaymentNumber() async => 'PAY-${_payments.length + 1}';
}