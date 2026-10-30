import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'customer_filter.dart';
import 'customer_model.dart';

// ============================================================
// CUSTOMER REPOSITORY INTERFACE
// ============================================================

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers({
    CustomerFilter? filter,
  });

  Future<CustomerModel> addCustomer(
    CustomerModel customer,
  );

  Future<CustomerModel> updateCustomer(
    CustomerModel customer,
  );

  Future<List<CustomerComment>> getCustomerComments(String customerId);

  Future<CustomerComment> addCustomerComment(
    String customerId,
    String comment,
  );

  Future<CustomerTransactions> getCustomerTransactions(String customerId);

  Future<CustomerStatement> getCustomerStatement(
    String customerId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<void> sendCustomerStatementEmail({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String recipientEmail,
    required String subject,
  });

  Future<void> deleteCustomer(
    String id,
  );
}

// ============================================================
// REAL API CUSTOMER REPOSITORY
// ============================================================

class ApiCustomerRepository implements CustomerRepository {
  static const String baseUrl = 'http://localhost:3000/api';

  @override
  Future<List<CustomerComment>> getCustomerComments(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerId/comments'),
        headers: const {'Accept': 'application/json'},
      );
      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true ||
          body['data'] is! List) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to fetch customer comments'
              : 'Invalid response from server',
        );
      }

      return (body['data'] as List)
          .map(
            (item) => CustomerComment.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (error) {
      throw Exception('Unable to load customer comments: $error');
    }
  }

  @override
  Future<CustomerComment> addCustomerComment(
    String customerId,
    String comment,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/$customerId/comments'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'comment': comment}),
      );
      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic> ||
          response.statusCode != 201 ||
          body['success'] != true ||
          body['data'] is! Map) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to save customer comment'
              : 'Invalid response from server',
        );
      }

      return CustomerComment.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception('Unable to save customer comment: $error');
    }
  }

  @override
  Future<CustomerTransactions> getCustomerTransactions(
    String customerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerId/transactions'),
        headers: const {'Accept': 'application/json'},
      );
      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true ||
          body['data'] is! Map) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to fetch customer transactions'
              : 'Invalid response from server',
        );
      }

      return CustomerTransactions.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception('Unable to load customer transactions: $error');
    }
  }

  @override
  Future<CustomerStatement> getCustomerStatement(
    String customerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerId/statement')
            .replace(queryParameters: query),
        headers: const {'Accept': 'application/json'},
      );
      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true ||
          body['data'] is! Map) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to generate customer statement'
              : 'Invalid response from server',
        );
      }
      return CustomerStatement.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception('Unable to generate customer statement: $error');
    }
  }

  @override
  Future<void> sendCustomerStatementEmail({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String recipientEmail,
    required String subject,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/$customerId/statement/email'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'startDate': DateFormat('yyyy-MM-dd').format(startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(endDate),
          'recipientEmail': recipientEmail,
          'subject': subject,
        }),
      );
      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          response.statusCode != 200 ||
          body['success'] != true) {
        throw Exception(
          body is Map
              ? body['message'] ?? 'Failed to send customer statement email'
              : 'Invalid response from server',
        );
      }
    } catch (error) {
      throw Exception('Unable to send customer statement email: $error');
    }
  }

  // ==========================================================
  // GET CUSTOMERS
  // GET /api/customers
  // ==========================================================

  @override
  Future<List<CustomerModel>> getCustomers({
    CustomerFilter? filter,
  }) async {
    try {
      final Map<String, String> queryParams =
          filter?.toQueryParams() ?? <String, String>{};

      final Uri uri = Uri.parse(
        '$baseUrl/customers',
      ).replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final http.Response response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to fetch customers',
        );
      }

      final List<dynamic> data =
          body['data'] is List ? body['data'] : <dynamic>[];

      return data.map((dynamic item) {
        return CustomerModel.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        );
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load customers: $error',
      );
    }
  }

  // ==========================================================
  // ADD CUSTOMER
  // POST /api/customers
  // ==========================================================

  @override
  Future<CustomerModel> addCustomer(
    CustomerModel customer,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/customers',
      );

      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
          customer.toJson(),
        ),
      );

      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 201 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to create customer',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Customer data missing from server response',
        );
      }

      return CustomerModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to add customer: $error',
      );
    }
  }

  // ==========================================================
  // DELETE CUSTOMER
  // DELETE /api/customers/:id
  // ==========================================================

  @override
  Future<void> deleteCustomer(
    String id,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/customers/$id',
      );

      final http.Response response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to delete customer',
        );
      }
    } catch (error) {
      throw Exception(
        'Unable to delete customer: $error',
      );
    }
  }

  // ==========================================================
  // UPDATE CUSTOMER
  // PUT /api/customers/:id
  // ==========================================================

  @override
  Future<CustomerModel> updateCustomer(
    CustomerModel customer,
  ) async {
    try {
      if (customer.id == null || customer.id!.trim().isEmpty) {
        throw Exception(
          'Customer ID is missing',
        );
      }

      final Uri uri = Uri.parse(
        '$baseUrl/customers/${customer.id}',
      );

      final http.Response response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
          customer.toJson(),
        ),
      );

      final dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to update customer',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Customer data missing from server response',
        );
      }

      return CustomerModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to update customer: $error',
      );
    }
  }
}

// ============================================================
// BACKWARD COMPATIBILITY
// ============================================================
//
// Some existing Sales modules still call:
//
// InMemoryCustomerRepository()
//
// Examples:
// - Invoice
// - Delivery Challan
// - Payment Received
//
// Instead of breaking those screens,
// this class redirects them to the same real API repository.
//
// So even old code using:
//
// InMemoryCustomerRepository()
//
// will now load customers from MySQL through the Node API.
// ============================================================

class InMemoryCustomerRepository
 extends ApiCustomerRepository {
  InMemoryCustomerRepository();
}
