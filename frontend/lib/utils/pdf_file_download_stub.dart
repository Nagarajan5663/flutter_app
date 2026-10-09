import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> downloadPdfFile(Uint8List bytes, String fileName) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
    bytes: bytes,
  );
  return path != null;
}
