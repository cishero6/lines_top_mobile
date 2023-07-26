import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier{
  int _currentIndex = 0;

  int get index {
    return _currentIndex.toInt();
  }

  void setIndex(int newIndex){
    _currentIndex = newIndex;
    notifyListeners();
  }
}