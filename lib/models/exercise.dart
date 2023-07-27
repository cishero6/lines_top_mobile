

import 'dart:io';

import 'package:lines_top_mobile/models/lines_top_model.dart';

class Exercise extends LinesTopModel{
  @override
  String id = ''; //Идентификатор упражнения
  @override
  String title = ''; //Название упражнения
  String description = ''; //Описание упражнения
  File? video; //Cсылка на видео
  int version = 0;

  Exercise.empty();
  Exercise({this.id = '',this.title = '',this.description = '',this.video,this.version = 0});



}