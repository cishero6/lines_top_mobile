import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<File> fileFromAsset(String path) async {
  final byteData = await rootBundle.load(path);

  var tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/${path.replaceAll('/', '_')}').writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}