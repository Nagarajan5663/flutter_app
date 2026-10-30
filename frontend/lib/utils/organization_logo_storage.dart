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
  static const _storageKey = 'organization_logo';
  static OrganizationLogoData? _cachedLogo;

  static Future<OrganizationLogoData?> load() async {
    final cachedLogo = _cachedLogo;
    if (cachedLogo != null) return cachedLogo;

    final preferences = await SharedPreferences.getInstance();
    final savedLogo = preferences.getString(_storageKey);
    if (savedLogo == null) return null;

    final savedData = jsonDecode(savedLogo);
    if (savedData is! Map<String, dynamic> ||
        savedData['bytes'] is! String ||
        savedData['name'] is! String) {
      throw const FormatException('Saved organization logo is invalid');
    }

    final logo = OrganizationLogoData(
      bytes: base64Decode(savedData['bytes'] as String),
      name: savedData['name'] as String,
    );
    _cachedLogo = logo;
    return logo;
  }

  static Future<void> save(Uint8List bytes, String name) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode({
        'bytes': base64Encode(bytes),
        'name': name,
      }),
    );
    if (!saved) {
      throw StateError('The organization logo could not be saved');
    }
    _cachedLogo = OrganizationLogoData(bytes: bytes, name: name);
  }
}
