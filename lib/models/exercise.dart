

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lines_top_mobile/models/lines_top_model.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/file_from_url.dart';
import '../helpers/network_connectivity.dart';

class Exercise extends LinesTopModel{
  @override
  String id = ''; //Идентификатор упражнения
  @override
  String title = ''; //Название упражнения
  String description = ''; //Описание упражнения
  String exerciseListText = ''; //Текст под "упражнение"
  String repetitionListText = ''; //Текст под "уол-во повторений"
  File? video; //Cсылка на видео
  int version = 0;

  Exercise.empty();
  Exercise({this.id = '',this.title = '',this.description = '',this.exerciseListText = '',this.repetitionListText = '',this.video,this.version = 0});

  Future<void> fetchMissingFile()async{
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return;
    }
    var path =  (await getApplicationDocumentsDirectory()).path;
    try{
      var videoRef = FirebaseStorage.instance.ref('exercises/$id');
      var downloadURL = await videoRef.getDownloadURL();
      video = await fileFromUrl(downloadURL, id);
      video = await video!.copy('$path/$id.mov');      
      print('ex loaded missing');
    }catch(e){
      print('tried to load ex - failed');
      return;
    }
  }

}