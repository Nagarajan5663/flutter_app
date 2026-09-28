import 'dart:convert';

import 'package:http/http.dart' as http;

import '../item_model.dart';
import '../part_model.dart';

class ItemsPartsApi {
  static const String baseUrl =
      'http://localhost:3000/api';

  // ============================================================
  // ITEMS
  // ============================================================

  static Future<List<ItemModel>> getItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/items'),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to fetch items',
      );
    }

    final List data = body['data'] ?? [];

    return data
        .map(
          (item) => ItemModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<ItemModel> createItem(
    ItemModel item,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to create item',
      );
    }

    return ItemModel.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  static Future<ItemModel> updateItem(
    ItemModel item,
  ) async {
    if (item.id == null) {
      throw Exception('Item ID is missing');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/items/${item.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to update item',
      );
    }

    return ItemModel.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  static Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id'),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to delete item',
      );
    }
  }

  // ============================================================
  // PARTS
  // ============================================================

  static Future<List<PartModel>> getParts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/parts'),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to fetch parts',
      );
    }

    final List data = body['data'] ?? [];

    return data
        .map(
          (part) => PartModel.fromJson(
            Map<String, dynamic>.from(part),
          ),
        )
        .toList();
  }

  static Future<PartModel> createPart(
    PartModel part,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/parts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(part.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to create part',
      );
    }

    return PartModel.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  static Future<PartModel> updatePart(
    PartModel part,
  ) async {
    if (part.id == null) {
      throw Exception('Part ID is missing');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/parts/${part.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(part.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to update part',
      );
    }

    return PartModel.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  static Future<void> deletePart(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/parts/$id'),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to delete part',
      );
    }
  }
}