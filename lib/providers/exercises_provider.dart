import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/exercise.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';
import '../helpers/file_from_asset.dart';
import '../helpers/file_from_url.dart';
import '../helpers/network_connectivity.dart';
import 'trainings_provider.dart';

class ExercisesProvider with ChangeNotifier {
  List<Exercise> _items = [];
  List<Exercise> get items {
    return [..._items];
  }

  String loadingText = '';

  Future<bool> fetchAndSetItems(
      [BuildContext? ctx]) async {
    _items = [];
    //1 ЭТАП
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('exercises');
    if (itemsDB.isNotEmpty) {
      for (var item in itemsDB) {
        List<String> exList = [];
        List<String> repList = [];
        var docEx = jsonDecode(item['exercise_list_texts']);
        var docRep = jsonDecode(item['repetition_list_texts']);
        for(int i = 0;i<docEx.length;i++){
          exList.add(docEx[i]);
          repList.add(docRep[i]);
        }
        File? video;
        if(item['video'] == 'null'){
          video = null;
        }else{
          if(!(await File(item['video']).exists())){
            video = null;
          }else{
            video = File(item['video']);
          }
        }
        _items.add(
          Exercise(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            exerciseListTexts: exList ,
            repetitionListTexts: repList,
            video: video,
            version: item['version'],
          ),
        );
      }
    }
    //2
    var isOnline = await NetworkConnectivity.checkConnection();
    if (itemsDB.isNotEmpty && !isOnline) {
      return true;
    }
    if (itemsDB.isEmpty && !isOnline) {
      //load assets
      return true;
    }
    try {
      var qSnapshot =
          await FirebaseFirestore.instance.collection('exercises').get();
      var docs = qSnapshot.docs;

      List<Exercise> firebaseItems = [];
      for (var docSnapshot in docs) {
        var doc = docSnapshot.data();
        List<String> exList = [];
        List<String> repList = [];
        for(int i = 0;i<doc['exercise_list_texts'].length;i++){
          exList.add(doc['exercise_list_texts'][i]);
          repList.add(doc['repetition_list_texts'][i]);
        }
        Exercise exercise = Exercise(
          id: docSnapshot.id,
          title: doc['title'],
          exerciseListTexts: exList,
          repetitionListTexts: repList,
          description: doc['description'],
          version: doc['version'],
        );
        bool videoExists = false;
        var path = (await getApplicationDocumentsDirectory()).path;
        if(_items.indexWhere((element) => element.id == exercise.id) != -1){
          var dbEx = _items.singleWhere((element) => element.id == exercise.id);
          if ((dbEx.version == exercise.version) && (dbEx.video != null)){
            exercise.video = dbEx.video;
            videoExists = true;
          }
        }
        firebaseItems.add(exercise);
        DBHelper.insert('exercises', {
          'id': exercise.id,
          'title': exercise.title,
          'description': exercise.description,
          'exercise_list_texts': jsonEncode(exercise.exerciseListTexts),
          'repetition_list_texts': jsonEncode(exercise.repetitionListTexts),
          'version': exercise.version,
          'video': videoExists ? '$path/${exercise.id}.mov' : 'null',
        });

      }
      _items = [...firebaseItems];
    } on FirebaseException catch (error) {
      print(error);
      return false;
    }

    _items.sort((a,b)=> int.parse(a.id.split('_').last).compareTo(int.parse(b.id.split('_').last)));

  return true;

/*
    _items = [];
    var qSnapshot =
        await FirebaseFirestore.instance.collection('exercises').get();
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Exercise exercise = Exercise(
          id: doc.id, title: doc['title'], description: doc['description'],version: doc['version']);
      // var downloadURL = await storage.ref(doc['video_url']).getDownloadURL();
      // File file = await fileFromUrl(downloadURL);
      // exercise.video = file;
      //exercise.video = await fileFromAsset('assets/temp/placeholder_video.mp4');
      _items.add(exercise);
    }
    return [..._items];
    */
  }

  Future<void> addExercise(Exercise newExercise) async {
    loadingText = 'Создаём упражнение';
    notifyListeners(); 
    var collectionReference =
        FirebaseFirestore.instance.collection('exercises');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;

    int max = 0;
    for (var element in docs) { //ОПРЕДЕЛИТЬ НОВЫЙ АЙДИ
      if (max < int.parse(element.id.split('_').last)) {
        max = int.parse(element.id.split('_').last);
      }
    }
    var newId = 'ex_${max + 1}';
    newExercise.id = newId;
    newExercise.version = 1;

    Map<String, dynamic> mapExercise = {
      'title': newExercise.title,
      'description': newExercise.description,
      'video': 'null',
      'exercise_list_texts': newExercise.exerciseListTexts,
      'repetition_list_texts': newExercise.repetitionListTexts,
      'version': 1,
    };
    var docReference = collectionReference.doc(newId);
    await docReference.set(mapExercise);
    loadingText = 'Загружаем видео';
    notifyListeners();
    final videoRef = FirebaseStorage.instance.ref('exercises/$newId');
    await videoRef.putFile(newExercise.video!).whenComplete(() {});
    loadingText = 'Обновляем упражнение';
    notifyListeners();
    await docReference.update({'video': 'exercises/$newId'});

    var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
    newExercise.video = await newExercise.video!.copy('$path/${newExercise.id}.mov');

    DBHelper.insert('exercises', {
      'id': newExercise.id,
      'title': newExercise.title,
      'description': newExercise.description,
      'exercise_list_texts': jsonEncode(newExercise.exerciseListTexts),
      'repetition_list_texts': jsonEncode(newExercise.repetitionListTexts),
      'version': 1,
      'video': '$path/${newExercise.id}.mov',
    });
    
    _items.add(newExercise);
    loadingText = '';
    notifyListeners();
  }

  Future<String?> editItem(
      Exercise exercise, Map<String, dynamic> newData) async {
    loadingText = 'Обновляем упражнение';
    notifyListeners();
    var path = (await getApplicationDocumentsDirectory()).path; 
    var item = _items.singleWhere((element) => element.id == exercise.id);
    var docRef = FirebaseFirestore.instance.doc('exercises/${exercise.id}');
    if (newData.containsKey('id')) {
      return 'Невозможно изменить документ: нельзя изменять идентификатор';
    }
    if (newData.containsKey('title')) {
      loadingText = 'Проверяем названия';
      notifyListeners();
      var collectionReference =
          FirebaseFirestore.instance.collection('exercises');
      var qSnapshot1 = await collectionReference.get();
      var exercises = qSnapshot1.docs;
      for (QueryDocumentSnapshot<Map<String, dynamic>> exMap in exercises) {
        if (exMap['title'] == newData['title']) {
          return 'Невозможно изменить документ: документ с таким названием уже есть!';
        }
      }
      item.title = newData['title'];
    }
    if (newData.containsKey('video')) {
      loadingText = 'Меняем видео';
      notifyListeners();
      var docRef = FirebaseStorage.instance.ref('exercises/${exercise.id}');
      await docRef.putFile(newData['video']);
      item.video = newData['video'];
      newData.remove('video');

      item.video = await item.video!.copy('$path/${item.id}');//COPY FILE IN DOCUMENTS

    }
    loadingText = 'Обновляем данные';
    notifyListeners();
    if (newData.containsKey('description')) {
      item.description = newData['description'];
    }
    if (newData.containsKey('exercise_list_texts')) {
      item.exerciseListTexts = newData['exercise_list_texts'];
    }
    if (newData.containsKey('repetition_list_texts')) {
      item.repetitionListTexts = newData['repetition_list_texts'];
    }
    newData.addAll({'version': exercise.version + 1});
    await docRef.update(newData);


    await DBHelper.insert('exercises', { //INSERT EDITED POST IN DATABASE
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'exercise_list_texts': jsonEncode(item.exerciseListTexts) ,
      'repetition_list_texts': jsonEncode(item.repetitionListTexts) ,
      'video': '$path/${item.id}.mov',
      'version': item.version
    });
    notifyListeners();
    return null;
  }

  Future<String?> deleteItem(Exercise exercise, BuildContext context) async {
    loadingText = 'Обновляем тренировки';
    notifyListeners();
    String? result =
        await Provider.of<TrainingsProvider>(context, listen: false)
            .removeExercise(exercise);
    if (result != null) return result;
    loadingText = 'Удаляем упражнение';
    notifyListeners();
    var videoRef = FirebaseStorage.instance.ref('exercises/${exercise.id}');
    await videoRef.delete();
    var docRef = FirebaseFirestore.instance.doc('exercises/${exercise.id}');
    await docRef.delete();
    _items.removeWhere((element) => element.id == exercise.id);
    // ignore: use_build_context_synchronously
    notifyListeners();
    loadingText = '';
    return null;
  }

  Future<void> fetchVideo(Exercise exercise) async {
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('exercises');
    if ((itemsDB.indexWhere((element) => element['id'] == exercise.id) == -1) ||
        (itemsDB.singleWhere(
                (element) => element['id'] == exercise.id)['version'] !=
            exercise.version) || itemsDB.singleWhere(
                (element) => element['id'] == exercise.id)['video'] == 'null') {
      print('start ex LOAD');
      var docRef = FirebaseFirestore.instance.doc('exercises/${exercise.id}');
      var doc = await docRef.get();
      var videoRef = FirebaseStorage.instance.ref('exercises/${exercise.id}');
      var downloadURL = await videoRef.getDownloadURL();
      exercise.video = await fileFromUrl(downloadURL, exercise.id);
      var path = (await getApplicationDocumentsDirectory()).path;
      exercise.video = await exercise.video!.copy('$path/${exercise.id}.mov');
      exercise.version = doc.data()!['version'];
      DBHelper.insert('exercises', {
        'id': exercise.id,
        'title': exercise.title,
        'video': '$path/${exercise.id}.mov',
        'exercise_list_texts': jsonEncode(exercise.exerciseListTexts) ,
        'repetition_list_texts': jsonEncode(exercise.repetitionListTexts) ,
        'description': exercise.description,
        'version': exercise.version,
      });
    } else {
      print('start ex EXIST');
      var itemFromDB =
          itemsDB.firstWhere((element) => element['id'] == exercise.id);
      File file = File(itemFromDB['video']);
      exercise.video = file;
    }
  }



  Future<void>  compileDatabaseIntoPreload()async{
    List<Map<String,dynamic>> compiledList = [];
    for(var item in items){
      Map<String,dynamic> mapItem = {
        'id':item.id,
        'title': item.title,
        'description': item.description,
        'exercise_list_texts': jsonEncode(item.exerciseListTexts),
        'repetitions_list_texts': jsonEncode(item.repetitionListTexts),
        'version': item.version,
      };
      compiledList.add(mapItem);
    }
    await FirebaseFirestore.instance.doc('dev/pre_compiled_data').update({'exercises':jsonEncode(compiledList)});
  }
  

  Future<void> firstLoadItems() async {
    _items = [];
    var path = (await getApplicationDocumentsDirectory()).path;
    var file = await fileFromAsset('assets/content/exercises.txt');
    var fileStr = await file.readAsString();
     List<dynamic> compiledListDynamic = jsonDecode(fileStr);
    List<Map<String, dynamic>> compiledList = [];
    for(var item in compiledListDynamic){
      compiledList.add(item);
    }
    for (Map<String, dynamic> item in compiledList) {
      Exercise exercise = Exercise(
          id: item['id'],
          title: item['title'],
          description: item['description']);
      File video = File('$path/${exercise.id}.mov');
      exercise.video = video;
      List<dynamic> ldynamic = jsonDecode(item['exercise_list_texts']);
      List<String> lstring = ldynamic.map((e) => e.toString()).toList();
      exercise.exerciseListTexts = lstring;
      ldynamic = jsonDecode(item['repetitions_list_texts']);
      lstring = ldynamic.map((e) => e.toString()).toList();
      exercise.repetitionListTexts = lstring;
      _items.add(exercise);
      DBHelper.insert('exercises', {
          'id': exercise.id,
          'title': exercise.title,
          'description': exercise.description,
          'exercise_list_texts': jsonEncode(exercise.exerciseListTexts),
          'repetition_list_texts': jsonEncode(exercise.repetitionListTexts),
          'version': exercise.version,
          'video': '$path/${exercise.id}.mov',
      });

    }
  }
}
