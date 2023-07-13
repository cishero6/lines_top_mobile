import 'package:flutter/material.dart';

class SectionNameProvider with ChangeNotifier{
  String _sectionName = '';

  String get sectionName{
    return _sectionName;
  }

  void setSectionName(String name){
    _sectionName = name;
    notifyListeners();
  }
  void initiateSectionName(String name){
    _sectionName = name;
  }
}