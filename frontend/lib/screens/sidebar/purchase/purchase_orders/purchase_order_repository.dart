import 'dart:convert';

import 'package:http/http.dart' as http;

import 'purchase_order_filter.dart';
import 'purchase_order_model.dart';

// ============================================================
// REPOSITORY INTERFACE
// ============================================================

abstract class PurchaseOrderRepository {
  Future<List<PurchaseOrderModel>> getPurchaseOrders({
    PurchaseOrderFilter? filter,
  });

  Future<PurchaseOrderModel> addPurchaseOrder(
    PurchaseOrderModel order,
  );

  Future<void> updatePurchaseOrder(
    PurchaseOrderModel order,
  );

  Future<void> deletePurchaseOrder(
    String id,
  );

  Future<void> updateStatus(
    String id,
    String status,
  );

  Future<String> nextPoNumber();
}

// ============================================================
// API REPOSITORY
// ============================================================

class ApiPurchaseOrderRepository implements PurchaseOrderRepository {
  static const String baseUrl = 'http://localhost:3000/api';

  // ==========================================================
  // GET PURCHASE ORDERS
  // ==========================================================

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders({
    PurchaseOrderFilter? filter,
  }) async {
    try {
      final Map<String, String> queryParams =
          filter?.toQueryParams() ?? <String, String>{};

      final Uri uri = Uri.parse(
        '$baseUrl/purchase-orders',
      ).replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final http.Response response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to fetch purchase orders',
        );
      }

      final List<dynamic> data =
          body['data'] is List ? body['data'] : <dynamic>[];

      return data.map(
        (dynamic raw) {
          return PurchaseOrderModel.fromJson(
            Map<String, dynamic>.from(
              raw as Map,
            ),
          );
        },
      ).toList();
    } catch (error) {
      throw Exception(
        'Unable to load purchase orders: $error',
      );
    }
  }

  @override
  Future<void> updatePurchaseOrder(PurchaseOrderModel order) async {
    final id = order.id;
    if (id == null || id.trim().isEmpty) {
      throw Exception('Purchase order ID is missing');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/purchase-orders/$id'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(order.toJson()),
      );
      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to update purchase order'
              : 'Failed to update purchase order',
        );
      }
    } catch (error) {
      throw Exception('Unable to update purchase order: $error');
    }
  }

  // ==========================================================
  // ADD PURCHASE ORDER
  // ==========================================================

  @override
  Future<PurchaseOrderModel> addPurchaseOrder(
    PurchaseOrderModel order,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/purchase-orders',
      );

      final http.Response response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
          order.toJson(),
        ),
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 201 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to create purchase order',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Purchase order data missing from response',
        );
      }

      return PurchaseOrderModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to create purchase order: $error',
      );
    }
  }

  // ==========================================================
  // DELETE PURCHASE ORDER
  // ==========================================================

  @override
  Future<void> deletePurchaseOrder(
    String id,
  ) async {
    try {
      if (id.trim().isEmpty) {
        throw Exception(
          'Purchase order ID is missing',
        );
      }

      final Uri uri = Uri.parse(
        '$baseUrl/purchase-orders/$id',
      );

      final http.Response response = await http.delete(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to delete purchase order',
        );
      }
    } catch (error) {
      throw Exception(
        'Unable to delete purchase order: $error',
      );
    }
  }

  // ==========================================================
  // NEXT PO NUMBER
  // ==========================================================

  @override
  Future<String> nextPoNumber() async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/purchase-orders/next-number',
      );

      final http.Response response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to generate PO number',
        );
      }

      return body['data']?['poNumber']?.toString() ?? 'PO-1';
    } catch (error) {
      throw Exception(
        'Unable to generate PO number: $error',
      );
    }
  }

  // ==========================================================
  // GET SINGLE PURCHASE ORDER
  // ==========================================================

  Future<PurchaseOrderModel> getPurchaseOrderById(
    String id,
  ) async {
    try {
      final http.Response response = await http.get(
        Uri.parse(
          '$baseUrl/purchase-orders/$id',
        ),
        headers: const {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to fetch purchase order'
              : 'Failed to fetch purchase order',
        );
      }

      return PurchaseOrderModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to fetch purchase order: $error',
      );
    }
  }

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  @override
  Future<void> updateStatus(
    String id,
    String status,
  ) async {
    try {
      final http.Response response = await http.put(
        Uri.parse(
          '$baseUrl/purchase-orders/$id/status',
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      final dynamic body = jsonDecode(
        response.body,
      );

      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to update status'
              : 'Failed to update status',
        );
      }
    } catch (error) {
      throw Exception(
        'Unable to update purchase order status: $error',
      );
    }
  }
}

// ============================================================
// BACKWARD COMPATIBILITY
//
// Existing files currently use:
//
// InMemoryPurchaseOrderRepository()
//
// Keep that name so PurchaseOrdersPage and other existing
// Purchase files continue compiling, but now it uses the API.
// ============================================================

class InMemoryPurchaseOrderRepository extends ApiPurchaseOrderRepository {
  InMemoryPurchaseOrderRepository();
}
