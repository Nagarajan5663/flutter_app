import 'sales_order_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class SalesOrderRepository {
  Future<List<SalesOrderModel>> getSalesOrders();
  Future<SalesOrderModel> addSalesOrder(SalesOrderModel order);
}

class InMemorySalesOrderRepository implements SalesOrderRepository {
  InMemorySalesOrderRepository._internal();
  static final InMemorySalesOrderRepository instance = InMemorySalesOrderRepository._internal();
  factory InMemorySalesOrderRepository() => instance;

  static const String _baseUrl = 'http://localhost:3000/api';

  @override
  Future<List<SalesOrderModel>> getSalesOrders() async {
    final response = await http.get(Uri.parse('$_baseUrl/sales-orders'), headers: const {'Accept': 'application/json'});
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body is! Map<String, dynamic> || body['success'] != true) {
      throw Exception(body is Map ? body['message'] ?? 'Failed to fetch Sales Orders' : 'Failed to fetch Sales Orders');
    }
    return (body['data'] as List? ?? []).map((e) => SalesOrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<SalesOrderModel> addSalesOrder(SalesOrderModel order) async {
    throw UnsupportedError('Sales Orders must be created through the approved document workflow.');
  }
}
