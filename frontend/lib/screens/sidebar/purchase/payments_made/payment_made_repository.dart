import 'dart:convert';

import 'package:http/http.dart' as http;

import 'payment_made_model.dart';

class PaymentMadeRepository {
  static const _baseUrl = 'http://localhost:3000/api';

  Future<void> updatePayment(PaymentMadeModel payment) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/bills/payments-made/${payment.id}'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'amount': payment.amount,
        'date': _date(payment.date),
        'mode': payment.mode,
        'reference': payment.reference,
        'paidBy': payment.paidBy,
        'notes': payment.notes,
      }),
    );
    _checkSuccess(response, 'Failed to update payment');
  }

  Future<void> deletePayment(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/bills/payments-made/$id'),
      headers: const {'Accept': 'application/json'},
    );
    _checkSuccess(response, 'Failed to delete payment');
  }

  Future<List<PaymentMadeModel>> getPayments({
    String vendor = '',
    String billNumber = '',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = <String, String>{};
    if (vendor.trim().isNotEmpty) query['vendor'] = vendor.trim();
    if (billNumber.trim().isNotEmpty) {
      query['billNumber'] = billNumber.trim();
    }
    if (dateFrom != null) {
      query['dateFrom'] = _date(dateFrom);
    }
    if (dateTo != null) query['dateTo'] = _date(dateTo);

    final uri = Uri.parse('$_baseUrl/bills/payments-made').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    final dynamic body = jsonDecode(response.body);
    final message = body is Map
        ? body['message']?.toString() ?? 'Failed to load payments'
        : 'Invalid response from server';
    if (response.statusCode == 404 && message == 'Bill not found') {
      throw Exception(
        'The backend is treating the Payments Made request as a bill lookup. '
        'Restart the backend server to load the Payments Made API.',
      );
    }
    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true ||
        body['data'] is! List) {
      throw Exception(message);
    }
    return (body['data'] as List)
        .map(
          (entry) => PaymentMadeModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  void _checkSuccess(http.Response response, String fallback) {
    final dynamic body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map ? body['message'] ?? fallback : 'Invalid server response',
      );
    }
  }
}
