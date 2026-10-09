import 'dart:convert';

import 'package:http/http.dart' as http;

import '../workflow_session.dart';
import 'payment_received_filter.dart';
import 'payment_received_model.dart';

abstract class PaymentReceivedRepository {
  Future<List<PaymentReceivedModel>> getPayments({
    PaymentReceivedFilter? filter,
  });
  Future<PaymentReceivedModel> addPayment(PaymentReceivedModel payment);
  Future<void> updatePayment(String id, PaymentReceivedModel payment);
  Future<void> deletePayment(String id);
  Future<String> nextPaymentNumber();
}

class InMemoryPaymentReceivedRepository implements PaymentReceivedRepository {
  InMemoryPaymentReceivedRepository._internal();

  static final InMemoryPaymentReceivedRepository instance =
      InMemoryPaymentReceivedRepository._internal();

  factory InMemoryPaymentReceivedRepository() => instance;

  static const String _baseUrl = 'http://localhost:3000/api';

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        ...SalesWorkflowSession.headers,
      };

  Future<Map<String, dynamic>> _request(
    http.Response response,
    Set<int> validStatusCodes,
  ) async {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        !validStatusCodes.contains(response.statusCode) ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Payment request failed'
            : 'Payment request failed',
      );
    }
    return body;
  }

  @override
  Future<List<PaymentReceivedModel>> getPayments({
    PaymentReceivedFilter? filter,
  }) async {
    final query = filter?.toQueryParams() ?? <String, String>{};
    final response = await http.get(
      Uri.parse('$_baseUrl/payments-received').replace(
        queryParameters: query.isEmpty ? null : query,
      ),
      headers: _headers,
    );
    final body = await _request(response, {200});
    return (body['data'] as List? ?? [])
        .map(
          (item) => PaymentReceivedModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<PaymentReceivedModel> addPayment(
    PaymentReceivedModel payment,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments-received'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(payment.toJson()),
    );
    final body = await _request(response, {201});
    return PaymentReceivedModel.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  @override
  Future<void> deletePayment(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/payments-received/$id'),
      headers: _headers,
    );
    await _request(response, {200});
  }

  @override
  Future<void> updatePayment(
    String id,
    PaymentReceivedModel payment,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/payments-received/$id'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(payment.toJson()),
    );
    await _request(response, {200});
  }

  @override
  Future<String> nextPaymentNumber() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments-received/next-number'),
      headers: _headers,
    );
    final body = await _request(response, {200});
    return body['data']?['paymentNumber']?.toString() ?? 'PAY-0001';
  }
}
