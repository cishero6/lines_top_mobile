import 'package:flutter/cupertino.dart';

class VerificationIdProvider with ChangeNotifier {
  String _verificationId = '';

  void setVerificationId(String newId) {
    _verificationId = newId;
    notifyListeners();
    return;
  }

  String get verificationId {
    return _verificationId;
  }

}
