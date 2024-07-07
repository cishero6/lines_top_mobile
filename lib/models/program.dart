import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lines_top_mobile/models/lines_top_model.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/db_helper.dart';
import '../helpers/file_from_url.dart';
import '../helpers/network_connectivity.dart';
import 'training.dart';

class Program extends LinesTopModel{
  @override
  String id = ''; //Идентификатор программы
  @override
  String title = ''; //Название программы
  String subtext = ''; //Текст, отображаемый на виджете в списке программ
  String bodyText = ''; //Подробное описание программы
  bool isFree = true; //Переменная идентифицирует, является ли программа полносьтью бесплатной
  File? image;
  List<Training> trainings = []; //Список, содержащий id тренировок
  int version = 0; //Версия программы

  Program({this.id = '',this.title = '',this.subtext = '',this.bodyText = '',List<Training>? trainings,this.image,this.isFree = true,this.version = 0}){
    this.trainings = trainings ?? [];
  }
  Program.empty();



  Future<void> fetchMissingFile()async{
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return;
    }
    try{
      var imageRef = FirebaseStorage.instance.ref('programs/$id');
      var downloadURL = await imageRef.getDownloadURL();
      File tempFile = await fileFromUrl(downloadURL, id);
      var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
      image = await tempFile.copy('$path/$id');
      await DBHelper.update('programs',{'id':id,'image': '$path/$id'});      
      print('pr loaded missing');
    }catch(e){
      print('tried to load pr - failed');
      return;
    }
  }
}