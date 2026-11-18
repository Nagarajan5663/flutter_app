import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/utils/organization_logo_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('organization logos persist per account', () async {
    SharedPreferences.setMockInitialValues({});
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await OrganizationLogoStorage.save(
      'owner@example.com',
      bytes,
      'organization.png',
    );

    final savedLogo = await OrganizationLogoStorage.load(
      'OWNER@example.com',
    );
    final otherAccountLogo = await OrganizationLogoStorage.load(
      'another@example.com',
    );

    expect(savedLogo?.name, 'organization.png');
    expect(savedLogo?.bytes, bytes);
    expect(otherAccountLogo, isNull);
  });
}
