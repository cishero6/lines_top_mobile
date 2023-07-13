import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> fileFromUrl(String url,String id)async {
  final http.Response responseData = await http.get(Uri.parse(url));
  var uint8list = responseData.bodyBytes;
  var buffer = uint8list.buffer;
  ByteData byteData = ByteData.view(buffer);
  var tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/$id').writeAsBytes(
    buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
}