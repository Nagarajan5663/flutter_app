import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_filter.dart';
import 'vendor_comment_model.dart';
import 'vendor_model.dart';

// ============================================================
// VENDOR REPOSITORY INTERFACE
// ============================================================

abstract class VendorRepository {
  Future<List<VendorModel>> getVendors({
    VendorFilter? filter,
  });

  Future<VendorModel> addVendor(
    VendorModel vendor,
  );

  Future<VendorModel> updateVendor(
    VendorModel vendor,
  );

  Future<VendorModel> getVendorById(
    String id,
  );

  Future<List<VendorComment>> getVendorComments(
    String vendorId,
  );

  Future<VendorComment> addVendorComment(
    String vendorId,
    String authorName,
    String comment,
  );

  Future<void> deleteVendor(
    String id,
  );
}

// ============================================================
// API VENDOR REPOSITORY
// ============================================================

class ApiVendorRepository implements VendorRepository {
  static const String baseUrl = 'http://localhost:3000/api';

  // ==========================================================
  // GET VENDORS
  //
  // GET /api/vendors
  // GET /api/vendors?status=Active
  // GET /api/vendors?city=Chennai
  // ==========================================================

  @override
  Future<List<VendorModel>> getVendors({
    VendorFilter? filter,
  }) async {
    try {
      final Map<String, String> queryParams =
          filter?.toQueryParams() ?? <String, String>{};

      final Uri uri = Uri.parse(
        '$baseUrl/vendors',
      ).replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final http.Response response = await http.get(
        uri,
        headers: {
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
          body['message'] ?? 'Failed to fetch vendors',
        );
      }

      final List<dynamic> data =
          body['data'] is List ? body['data'] : <dynamic>[];

      return data.map(
        (dynamic item) {
          return VendorModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();
    } catch (error) {
      throw Exception(
        'Unable to load vendors: $error',
      );
    }
  }

  // ==========================================================
  // ADD VENDOR
  //
  // POST /api/vendors
  // ==========================================================

  @override
  Future<VendorModel> addVendor(
    VendorModel vendor,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/vendors',
      );

      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
          vendor.toJson(),
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
          body['message'] ?? 'Failed to create vendor',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Vendor data missing from server response',
        );
      }

      return VendorModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to add vendor: $error',
      );
    }
  }

  // ==========================================================
  // UPDATE VENDOR
  //
  // PUT /api/vendors/:id
  // ==========================================================

  @override
  Future<VendorModel> updateVendor(
    VendorModel vendor,
  ) async {
    try {
      if (vendor.id == null || vendor.id!.trim().isEmpty) {
        throw Exception(
          'Vendor ID is missing',
        );
      }

      final Uri uri = Uri.parse(
        '$baseUrl/vendors/${vendor.id}',
      );

      final http.Response response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
          vendor.toJson(),
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

      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Failed to update vendor',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Vendor data missing from server response',
        );
      }

      return VendorModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to update vendor: $error',
      );
    }
  }

  // ==========================================================
  // DELETE VENDOR
  //
  // DELETE /api/vendors/:id
  // ==========================================================

  @override
  Future<void> deleteVendor(
    String id,
  ) async {
    try {
      if (id.trim().isEmpty) {
        throw Exception(
          'Vendor ID is missing',
        );
      }

      final Uri uri = Uri.parse(
        '$baseUrl/vendors/$id',
      );

      final http.Response response = await http.delete(
        uri,
        headers: {
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
          body['message'] ?? 'Failed to delete vendor',
        );
      }
    } catch (error) {
      throw Exception(
        'Unable to delete vendor: $error',
      );
    }
  }

  // ==========================================================
  // GET SINGLE VENDOR
  //
  // GET /api/vendors/:id
  // ==========================================================

  @override
  Future<VendorModel> getVendorById(
    String id,
  ) async {
    try {
      if (id.trim().isEmpty) {
        throw Exception(
          'Vendor ID is missing',
        );
      }

      final Uri uri = Uri.parse(
        '$baseUrl/vendors/$id',
      );

      final http.Response response = await http.get(
        uri,
        headers: {
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
          body['message'] ?? 'Failed to fetch vendor',
        );
      }

      if (body['data'] == null) {
        throw Exception(
          'Vendor data missing from server response',
        );
      }

      return VendorModel.fromJson(
        Map<String, dynamic>.from(
          body['data'] as Map,
        ),
      );
    } catch (error) {
      throw Exception(
        'Unable to fetch vendor: $error',
      );
    }
  }

  @override
  Future<List<VendorComment>> getVendorComments(String vendorId) async {
    try {
      if (vendorId.trim().isEmpty) {
        throw Exception('Vendor ID is missing');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vendors/$vendorId/comments'),
        headers: const {'Accept': 'application/json'},
      );
      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }
      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to load vendor comments');
      }
      final data = body['data'];
      if (data is! List) {
        throw Exception('Invalid comments data from server');
      }
      return data
          .map(
            (dynamic item) => VendorComment.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (error) {
      throw Exception('Unable to load vendor comments: $error');
    }
  }

  @override
  Future<VendorComment> addVendorComment(
    String vendorId,
    String authorName,
    String comment,
  ) async {
    try {
      if (vendorId.trim().isEmpty) {
        throw Exception('Vendor ID is missing');
      }
      if (comment.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }
      if (authorName.trim().isEmpty) {
        throw Exception('Comment author is missing');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/vendors/$vendorId/comments'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'authorName': authorName.trim(),
          'comment': comment.trim(),
        }),
      );
      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }
      if (response.statusCode != 201 || body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to save vendor comment');
      }
      if (body['data'] is! Map) {
        throw Exception('Comment data missing from server response');
      }
      return VendorComment.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception('Unable to save vendor comment: $error');
    }
  }
}

// ============================================================
// BACKWARD COMPATIBILITY
//
// Some existing Purchase modules may still call:
//
// InMemoryVendorRepository()
//
// Instead of breaking those files, keep the old class name,
// but internally it now uses the real API.
// ============================================================

class InMemoryVendorRepository extends ApiVendorRepository {
  InMemoryVendorRepository();
}
