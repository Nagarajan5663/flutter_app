import 'dart:typed_data';

import 'pdf_file_download_stub.dart'
    if (dart.library.html) 'pdf_file_download_web.dart' as platform;

Future<bool> downloadPdfFile(Uint8List bytes, String fileName) {
  return platform.downloadPdfFile(bytes, fileName);
}
