import 'dart:convert';

import 'package:http/http.dart' as http;

import 'bill_filter.dart';
import 'bill_model.dart';

// ============================================================
// REPOSITORY INTERFACE
// ============================================================

abstract class BillRepository {
  Future<List<BillModel>> getBills({
    BillFilter? filter,
  });

  Future<BillModel> addBill(
    BillModel bill,
  );

  Future<void> deleteBill(
    String id,
  );

  Future<String> nextBillNumber();

  Future<BillModel> recordPayment(
    String billId,
    double amountPaid,
  );
}

// ============================================================
// API BILL REPOSITORY
// ============================================================

class ApiBillRepository
    implements BillRepository {
  static const String baseUrl =
      'http://localhost:3000/api';

  // ==========================================================
  // GET BILLS
  // ==========================================================

  @override
  Future<List<BillModel>> getBills({
    BillFilter? filter,
  }) async {
    try {
      final Map<String, String>
          queryParams =
          filter?.toQueryParams() ??
              <String, String>{};

      final Uri uri = Uri.parse(
        '$baseUrl/bills',
      ).replace(
        queryParameters:
            queryParams.isEmpty
                ? null
                : queryParams,
      );

      final http.Response response =
          await http.get(
        uri,
        headers: const {
          'Accept':
              'application/json',
        },
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to fetch bills',
        );
      }

      final List<dynamic> data =
          body['data'] is List
              ? body['data']
              : <dynamic>[];

      return data.map(
        (dynamic raw) {
          return BillModel.fromJson(
            Map<String, dynamic>.from(
              raw as Map,
            ),
          );
        },
      ).toList();
    } catch (error) {
      throw Exception(
        'Unable to load bills: $error',
      );
    }
  }

  // ==========================================================
  // ADD BILL
  // ==========================================================

  @override
  Future<BillModel> addBill(
    BillModel bill,
  ) async {
    try {
      final Uri uri =
          Uri.parse(
        '$baseUrl/bills',
      );

      final http.Response response =
          await http.post(
        uri,
        headers: const {
          'Content-Type':
              'application/json',

          'Accept':
              'application/json',
        },
        body: jsonEncode(
          bill.toJson(),
        ),
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 201 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to create bill',
        );
      }

      if (
        body['data'] == null
      ) {
        throw Exception(
          'Bill data missing from server response',
        );
      }

      return BillModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to create bill: $error',
      );
    }
  }

  // ==========================================================
  // DELETE BILL
  // ==========================================================

  @override
  Future<void> deleteBill(
    String id,
  ) async {
    try {
      if (
        id.trim().isEmpty
      ) {
        throw Exception(
          'Bill ID is missing',
        );
      }

      final http.Response response =
          await http.delete(
        Uri.parse(
          '$baseUrl/bills/$id',
        ),
        headers: const {
          'Accept':
              'application/json',
        },
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to delete bill',
        );
      }
    } catch (error) {
      throw Exception(
        'Unable to delete bill: $error',
      );
    }
  }

  // ==========================================================
  // NEXT BILL NUMBER
  // ==========================================================

  @override
  Future<String>
      nextBillNumber() async {
    try {
      final http.Response response =
          await http.get(
        Uri.parse(
          '$baseUrl/bills/next-number',
        ),
        headers: const {
          'Accept':
              'application/json',
        },
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to generate bill number',
        );
      }

      return body['data']
                  ?['billNumber']
              ?.toString() ??
          'BILL-1';
    } catch (error) {
      throw Exception(
        'Unable to generate bill number: $error',
      );
    }
  }

  // ==========================================================
  // RECORD PAYMENT
  // ==========================================================

  @override
  Future<BillModel> recordPayment(
    String billId,
    double amountPaid,
  ) async {
    try {
      if (
        billId.trim().isEmpty
      ) {
        throw Exception(
          'Bill ID is missing',
        );
      }

      if (
        amountPaid <= 0
      ) {
        throw Exception(
          'Payment must be greater than zero',
        );
      }

      final http.Response response =
          await http.put(
        Uri.parse(
          '$baseUrl/bills/$billId/payment',
        ),
        headers: const {
          'Content-Type':
              'application/json',

          'Accept':
              'application/json',
        },
        body: jsonEncode({
          'amountPaid':
              amountPaid,
        }),
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to record payment',
        );
      }

      return BillModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to record payment: $error',
      );
    }
  }

  // ==========================================================
  // OPTIONAL: GET SINGLE BILL
  // ==========================================================

  Future<BillModel> getBillById(
    String id,
  ) async {
    try {
      final http.Response response =
          await http.get(
        Uri.parse(
          '$baseUrl/bills/$id',
        ),
        headers: const {
          'Accept':
              'application/json',
        },
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body is Map
              ? body['message'] ??
                  'Failed to fetch bill'
              : 'Failed to fetch bill',
        );
      }

      return BillModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to fetch bill: $error',
      );
    }
  }
}

// ============================================================
// BACKWARD COMPATIBILITY
//
// Existing BillsPage / dialogs currently use:
// InMemoryBillRepository()
//
// Keep the name, but it now connects to the real API.
// ============================================================

class InMemoryBillRepository
    extends ApiBillRepository {
  InMemoryBillRepository();
}