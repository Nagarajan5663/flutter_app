import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/utils/organization_logo_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('organization logo persists bytes and filename', () async {
    SharedPreferences.setMockInitialValues({});
    final bytes = Uint8List.fromList([0, 1, 2, 255]);

    await OrganizationLogoStorage.save(bytes, 'company-logo.png');
    final persistedLogo = await OrganizationLogoStorage.load();

    expect(persistedLogo, isNotNull);
    expect(persistedLogo!.bytes, bytes);
    expect(persistedLogo.name, 'company-logo.png');

    await (await SharedPreferences.getInstance()).clear();
    final logoAfterLogout = await OrganizationLogoStorage.load();

    expect(logoAfterLogout, isNotNull);
    expect(logoAfterLogout!.bytes, bytes);
    expect(logoAfterLogout.name, 'company-logo.png');
  });
}
