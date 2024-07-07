import 'package:flutter/material.dart';

class SectionNameProvider with ChangeNotifier{
  String _sectionName = '';
  int _index = 0;

  String get sectionName{
    return _sectionName;
  }
  int get getIndex{
    return _index;
  }

  void setSectionName(String name){
    _sectionName = name;
    _index++;
    if(_index == 4){
      _index = 0;
    }
    notifyListeners();
  }
  void initiateSectionName(String name){
    _sectionName = name;
  }
}