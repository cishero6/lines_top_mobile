import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/db_helper.dart';
import '../helpers/file_from_url.dart';
import '../helpers/network_connectivity.dart';
import 'exercise.dart';
import 'lines_top_model.dart';

class Training extends LinesTopModel{
  @override
  String id = ''; // Идентификатор тренировки
  @override
  String title = ''; //Название тренировки
  Map<String,List<Exercise>> sections = {}; //Секции
  Map<String,List<int>> exRepetitionsIds = {}; //Номер повторений для каждого упражнения
  bool isSet = false; //Является ли Сетом
  File? image; //Фотография (ТОЛЬКО ДЛЯ СЕТА)
  String? description; //Описание (ТОЛЬКО ДЛЯ СЕТА)
  @override
  int version = 0;//Версия 


  Training.empty();
  Training({this.id='',this.title = '',Map<String,List<Exercise>>? sections,Map<String,List<int>>? exRepetitionsIds,this.version = 0,this.isSet = false,this.image,this.description}){
    this.exRepetitionsIds = exRepetitionsIds ?? {};
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

  Future<void> fetchMissingFile()async{
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return;
    }
    try{
      if(image == null){
      var path =  await getApplicationDocumentsDirectory();
      image = File('$path/$id');
      }
      var downloadURL = await FirebaseStorage.instance.ref('trainings/$id').getDownloadURL();
      File tempFile = await fileFromUrl(downloadURL, 'trainings_$id');
      var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
      image = await tempFile.copy('$path/$id');
      await DBHelper.update('trainings',{'id':id,'image': '$path/$id'});      

      print('tr loaded missing');
    }catch(e){
      print('tried to load tr - failed');
      return;
    }
  }

}