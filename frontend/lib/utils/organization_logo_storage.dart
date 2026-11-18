import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class OrganizationLogoData {
  final Uint8List bytes;
  final String name;

  const OrganizationLogoData({
    required this.bytes,
    required this.name,
  });
}

class OrganizationLogoStorage {
  static const _storageKeyPrefix = 'organization_logo_';

  static Future<OrganizationLogoData?> load(String accountKey) async {
    final preferences = await SharedPreferences.getInstance();
    final savedLogo = preferences.getString(_storageKey(accountKey));
    if (savedLogo == null) return null;

    final savedData = jsonDecode(savedLogo);
    if (savedData is! Map<String, dynamic> ||
        savedData['bytes'] is! String ||
        savedData['name'] is! String) {
      throw const FormatException('Saved organization logo is invalid');
    }

    return OrganizationLogoData(
      bytes: base64Decode(savedData['bytes'] as String),
      name: savedData['name'] as String,
    );
  }

  static Future<void> save(
    String accountKey,
    Uint8List bytes,
    String name,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey(accountKey),
      jsonEncode({
        'bytes': base64Encode(bytes),
        'name': name,
      }),
    );
    if (!saved) {
      throw StateError('The organization logo could not be saved');
    }
  }

  static String _storageKey(String accountKey) =>
      '$_storageKeyPrefix${accountKey.trim().toLowerCase()}';
}
