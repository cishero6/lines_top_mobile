import 'package:flutter/cupertino.dart';

class VerificationIdProvider with ChangeNotifier {
  String _verificationId = '';

  void setVerificationId(String newId) {
    _verificationId = newId;
    notifyListeners();
    return;
  }

  void removeVerificationId() {
    _verificationId = '';
    return;
  }

  String get verificationId {
    return _verificationId;
  }

}
