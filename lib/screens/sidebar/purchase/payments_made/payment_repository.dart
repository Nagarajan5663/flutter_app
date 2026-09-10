import 'payment_filter.dart';
import 'payment_model.dart';

abstract class PaymentRepository {
  Future<List<PaymentModel>> getPayments({PaymentFilter? filter});
  Future<PaymentModel> addPayment(PaymentModel payment);
  Future<void> deletePayment(String id);
  Future<String> nextPaymentNumber();
}

/// Swap for ApiPaymentRepository later:
///   GET    $baseUrl/payments?...filter.toQueryParams()
///   POST   $baseUrl/payments   body: payment.toJson()
///   DELETE $baseUrl/payments/$id
class InMemoryPaymentRepository implements PaymentRepository {
  InMemoryPaymentRepository._internal();
  static final InMemoryPaymentRepository instance = InMemoryPaymentRepository._internal();
  factory InMemoryPaymentRepository() => instance;

  final List<PaymentModel> _payments = [];
  int _nextId = 1;

  @override
  Future<List<PaymentModel>> getPayments({PaymentFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<PaymentModel>.from(_payments);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<PaymentModel> addPayment(PaymentModel payment) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = payment.copyWith(id: (_nextId++).toString());
    _payments.add(withId);
    return withId;
  }

  @override
  Future<void> deletePayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _payments.removeWhere((p) => p.id == id);
  }

  @override
  Future<String> nextPaymentNumber() async {
    return 'PAY-${_payments.length + 1}';
  }
}