import 'invoice_filter.dart';
import 'invoice_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../workflow_session.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceModel>> getInvoices({InvoiceFilter? filter});
  Future<InvoiceModel> addInvoice(InvoiceModel invoice);
  Future<InvoiceModel> updateInvoice(InvoiceModel invoice);
  Future<InvoiceModel> cloneInvoice(String id);
  Future<InvoiceModel> updateStatus(String id, String status);
  Future<void> deleteInvoice(String id);
  Future<void> sendInvoiceEmail({
    required String id,
    required String subject,
  });
  Future<String> nextInvoiceNumber();
  Future<InvoiceModel> approveInvoice(String id);
  Future<InvoiceModel> createFromSalesOrder(String id);
}

class InMemoryInvoiceRepository implements InvoiceRepository {
  InMemoryInvoiceRepository._internal();
  static final InMemoryInvoiceRepository instance = InMemoryInvoiceRepository._internal();
  factory InMemoryInvoiceRepository() => instance;

  static const String _baseUrl = 'http://localhost:3000/api';

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    ...SalesWorkflowSession.headers,
  };

  Future<Map<String, dynamic>> _request(http.Response response, Set<int> codes) async {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || !codes.contains(response.statusCode) || body['success'] != true) {
      throw Exception(body is Map ? body['message'] ?? 'Invoice request failed' : 'Invoice request failed');
    }
    return body;
  }

  @override
  Future<List<InvoiceModel>> getInvoices({InvoiceFilter? filter}) async {
    final query = filter?.toQueryParams() ?? <String, String>{};
    final response = await http.get(Uri.parse('$_baseUrl/invoices').replace(queryParameters: query.isEmpty ? null : query), headers: _headers);
    final body = await _request(response, {200});
    return (body['data'] as List? ?? []).map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<InvoiceModel> addInvoice(InvoiceModel invoice) async {
    final response = await http.post(Uri.parse('$_baseUrl/invoices'), headers: {..._headers, 'Content-Type': 'application/json'}, body: jsonEncode(invoice.toJson()));
    final body = await _request(response, {201});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<InvoiceModel> updateInvoice(InvoiceModel invoice) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/invoices/${invoice.id}'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toJson()),
    );
    final body = await _request(response, {200});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<InvoiceModel> cloneInvoice(String id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/invoices/$id/clone'),
      headers: _headers,
    );
    final body = await _request(response, {201});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<InvoiceModel> updateStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/invoices/$id/status'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    final body = await _request(response, {200});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<void> sendInvoiceEmail({
    required String id,
    required String subject,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/invoices/$id/email'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'subject': subject}),
    );
    await _request(response, {200});
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/invoices/$id'), headers: _headers);
    await _request(response, {200});
  }

  @override
  Future<String> nextInvoiceNumber() async {
    final response = await http.get(Uri.parse('$_baseUrl/invoices/next-number'), headers: _headers);
    final body = await _request(response, {200});
    return body['data']?['invoiceNumber']?.toString() ?? 'INV-0001';
  }

  @override
  Future<InvoiceModel> approveInvoice(String id) async {
    final response = await http.post(Uri.parse('$_baseUrl/invoices/$id/approve'), headers: _headers);
    final body = await _request(response, {200});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<InvoiceModel> createFromSalesOrder(String id) async {
    final response = await http.post(Uri.parse('$_baseUrl/invoices/from-sales-order/$id'), headers: _headers);
    final body = await _request(response, {200, 201});
    return InvoiceModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }
}
