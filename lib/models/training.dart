import 'dart:io';

import 'exercise.dart';
import 'lines_top_model.dart';

class Training extends LinesTopModel{
  @override
  String id = ''; // Идентификатор тренировки
  @override
  String title = ''; //Название тренировки
  Map<String,List<Exercise>> sections = {}; //Секции
  bool isSet = false; //Является ли Сетом
  File? image; //Фотография (ТОЛЬКО ДЛЯ СЕТА)
  String? description; //Описание (ТОЛЬКО ДЛЯ СЕТА)
  @override
  int version = 0;//Версия 


  Training.empty();
  Training({this.id='',this.title = '',Map<String,List<Exercise>>? sections,this.version = 0,this.isSet = false,this.image,this.description}){
    this.sections = sections ?? {};
    if (!isSet && image != null){
      image = null;
    }
    if(!isSet && description == null){
      description = null;
    }
  }
  @override
  String toString() {
    return 'Training - $id';
  }

}