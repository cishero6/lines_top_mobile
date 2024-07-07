import 'dart:async';
import 'dart:io';


class NetworkConnectivity {
static Future<bool> checkConnection() async {
  bool isOnline = false;
  try {
    final result = await InternetAddress.lookup('example.com');
    isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    isOnline = false;
  }
  print('connection - $isOnline');
  return isOnline;
}
}


