import 'delivery_challan_filter.dart';
import 'delivery_challan_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../workflow_session.dart';

abstract class DeliveryChallanRepository {
  Future<List<DeliveryChallanModel>> getChallans(
      {DeliveryChallanFilter? filter});
  Future<DeliveryChallanModel> addChallan(DeliveryChallanModel challan);
  Future<void> deleteChallan(String id);
  Future<String> nextChallanNumber();
  Future<DeliveryChallanModel> createFromInvoice(String id);
  Future<DeliveryChallanModel> createFromSalesOrder(String id);
  Future<void> updateStatus(String id, String status);
  Future<void> updateDetails(
    String id, {
    required DateTime? deliveryDate,
    required String transportationDetails,
  });
  Future<DeliveryChallanModel> cloneChallan(String id);
}

class InMemoryDeliveryChallanRepository implements DeliveryChallanRepository {
  InMemoryDeliveryChallanRepository._internal();
  static final InMemoryDeliveryChallanRepository instance =
      InMemoryDeliveryChallanRepository._internal();
  factory InMemoryDeliveryChallanRepository() => instance;

  static const String _baseUrl = 'http://localhost:3000/api';
  Map<String, String> get _headers =>
      {'Accept': 'application/json', ...SalesWorkflowSession.headers};

  Future<Map<String, dynamic>> _request(
      http.Response response, Set<int> codes) async {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        !codes.contains(response.statusCode) ||
        body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Delivery Challan request failed'
          : 'Delivery Challan request failed');
    }
    return body;
  }

  @override
  Future<List<DeliveryChallanModel>> getChallans(
      {DeliveryChallanFilter? filter}) async {
    final query = filter?.toQueryParams() ?? <String, String>{};
    final response = await http.get(
        Uri.parse('$_baseUrl/delivery-challans')
            .replace(queryParameters: query.isEmpty ? null : query),
        headers: _headers);
    final body = await _request(response, {200});
    return (body['data'] as List? ?? [])
        .map((e) =>
            DeliveryChallanModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<DeliveryChallanModel> addChallan(DeliveryChallanModel challan) async {
    if (challan.invoiceId != null) return createFromInvoice(challan.invoiceId!);
    final response = await http.post(Uri.parse('$_baseUrl/delivery-challans'),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(challan.toJson()));
    final body = await _request(response, {201});
    return DeliveryChallanModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<void> deleteChallan(String id) async {
    final response = await http.delete(
        Uri.parse('$_baseUrl/delivery-challans/$id'),
        headers: _headers);
    await _request(response, {200});
  }

  @override
  Future<String> nextChallanNumber() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/delivery-challans/next-number'),
        headers: _headers);
    final body = await _request(response, {200});
    return body['data']?['challanNumber']?.toString() ?? 'DC-0001';
  }

  @override
  Future<DeliveryChallanModel> createFromInvoice(String id) async {
    final response = await http.post(
        Uri.parse('$_baseUrl/delivery-challans/from-invoice/$id'),
        headers: _headers);
    final body = await _request(response, {200, 201});
    return DeliveryChallanModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<DeliveryChallanModel> createFromSalesOrder(String id) async {
    final response = await http.post(
        Uri.parse('$_baseUrl/delivery-challans/from-sales-order/$id'),
        headers: _headers);
    final body = await _request(response, {200, 201});
    return DeliveryChallanModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    final response = await http.put(
        Uri.parse('$_baseUrl/delivery-challans/$id/status'),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}));
    await _request(response, {200});
  }

  @override
  Future<void> updateDetails(
    String id, {
    required DateTime? deliveryDate,
    required String transportationDetails,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/delivery-challans/$id'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'deliveryDate': deliveryDate == null
            ? null
            : '${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}',
        'transportationDetails': transportationDetails,
      }),
    );
    await _request(response, {200});
  }

  @override
  Future<DeliveryChallanModel> cloneChallan(String id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/delivery-challans/$id/clone'),
      headers: _headers,
    );
    final body = await _request(response, {201});
    return DeliveryChallanModel.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }
}
