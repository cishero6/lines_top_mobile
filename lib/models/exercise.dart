

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
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
  List<String> exerciseListTexts = []; //Текст под "упражнение"
  List<String> repetitionListTexts = []; //Текст под "уол-во повторений"
  File? video; //Cсылка на видео
  int version = 0;

  Exercise.empty();
  Exercise({this.id = '',this.title = '',this.description = '',List<String>? exerciseListTexts,List<String>? repetitionListTexts,this.video,this.version = 0}){
    this.exerciseListTexts = exerciseListTexts ?? [];
    this.repetitionListTexts = repetitionListTexts ?? [];
  }

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
      await DBHelper.update('exercises',{'id':id,'video': '$path/$id.mov'});      
      print('ex loaded missing');
    }catch(e){
      print('tried to load ex - failed');
      return;
    }
  }
  Future<bool> isUpdateNeeded()async{
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return false;
    }
    var doc = await FirebaseFirestore.instance.doc('exercises/$id').get();
    return doc.data()!['version'] != version;
  }

  @override
  String toString() {
    // TODO: implement toString
    return id;
  }

}