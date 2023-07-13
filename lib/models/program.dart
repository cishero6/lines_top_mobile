import 'dart:io';

import 'package:lines_top_mobile/models/lines_top_model.dart';

import 'training.dart';

class Program extends LinesTopModel{
  @override
  String id = ''; //Идентификатор программы
  @override
  String title = ''; //Название программы
  String subtext = ''; //Текст, отображаемый на виджете в списке программ
  String bodyText = ''; //Подробное описание программы
  bool isFree = true; //Переменная идентифицирует, является ли программа полносьтью бесплатной
  File image = File('assets/temp/bubbles1.jpeg');
  List<Training> trainings = []; //Список, содержащий id тренировок

  Program({this.id = '',this.title = '',this.subtext = '',this.bodyText = '',List<Training>? trainings,File? image,this.isFree = true}){
    this.image = image ?? File('assets/temp/bubbles1.jpeg');
    this.trainings = trainings ?? [];
  }
  Program.empty();

}