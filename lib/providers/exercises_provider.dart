import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/file_from_asset.dart';
import 'package:lines_top_mobile/models/exercise.dart';
import 'package:provider/provider.dart';

import '../helpers/file_from_url.dart';
import 'trainings_provider.dart';

class ExercisesProvider with ChangeNotifier {
  List<Exercise> _items = [];
  List<Exercise> get items {
    return [..._items];
  }
  String loadingText = '';

  Future<List<Exercise>> fetchAndSetItems([BuildContext? ctx]) async {
    _items = [];
    var qSnapshot =
        await FirebaseFirestore.instance.collection('exercises').get();
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Exercise exercise = Exercise(
          id: doc.id, title: doc['title'], description: doc['description']);
      // var downloadURL = await storage.ref(doc['video_url']).getDownloadURL();
      // File file = await fileFromUrl(downloadURL);
      // exercise.video = file;
      exercise.video = await fileFromAsset('assets/temp/placeholder_video.mp4');
      _items.add(exercise);
    }
    return [..._items];
  }

  Future<void> addExercise(Exercise newExercise) async {
    loadingText = 'Создаём упражнение';
    notifyListeners();
    var collectionReference =
        FirebaseFirestore.instance.collection('exercises');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;
    int max = 0;
    for (var element in docs) {
      if (max < int.parse(element.id.split('_').last)) {
        max = int.parse(element.id.split('_').last);
      }
    }
    var newId = 'ex_${max + 1}';
    newExercise.id = newId;
    Map<String, dynamic> mapExercise = {
      'title': newExercise.title,
      'description': newExercise.description,
      'video_url': 'null',
    };
    var docReference = collectionReference.doc(newId);
    await docReference.set(mapExercise);
    loadingText = 'Загружаем видео';
    notifyListeners();
    final videoRef = FirebaseStorage.instance.ref('exercises/$newId');
    await videoRef.putFile(newExercise.video!).whenComplete(() {});
    loadingText = 'Обновляем упражнение';
    notifyListeners();
    await docReference.update({'video_url': 'exercises/$newId'});
    _items.add(newExercise);
    loadingText = '';
    notifyListeners();
  }

  Future<void> addExerciseFromMap(Map<String, dynamic> map) async {
    Exercise newExercise = Exercise(
        title: map['title'],
        description: map['description'],
        video: map['video']);
    await addExercise(newExercise);
  }

  Future<void> addExerciseFromMapWithLink(Map<String, dynamic> map) async {
    Exercise newExercise =
        Exercise(title: map['title'], description: map['description']);
    var videoRef = FirebaseStorage.instance.ref(map['video_url']);
    var url = await videoRef.getDownloadURL();
    newExercise.video = File.fromUri(Uri.parse(url));
    await addExercise(newExercise);
  }

  Future<String?> editItem(Exercise exercise,Map<String,dynamic> newData) async {
  loadingText = 'Обновляем упражнение';
  notifyListeners();
  var item = _items.singleWhere((element) => element.id == exercise.id);
    var docRef = FirebaseFirestore.instance.doc('exercises/${exercise.id}');
    if(newData.containsKey('id')){
      return 'Невозможно изменить документ: нельзя изменять идентификатор';
    }
    if(newData.containsKey('title')){
        loadingText = 'Проверяем названия';
        notifyListeners();
      var collectionReference = FirebaseFirestore.instance.collection('exercises');
      var qSnapshot1 = await collectionReference.get();
      var exercises = qSnapshot1.docs;
       for(QueryDocumentSnapshot<Map<String, dynamic>> exMap in exercises){
        if (exMap['title'] == newData['title']){
          return 'Невозможно изменить документ: документ с таким названием уже есть!';
        }
      }
      item.title = newData['title'];
    }
    if(newData.containsKey('video')){
      loadingText = 'Меняем видео';
        notifyListeners();
      var docRef = FirebaseStorage.instance.ref('exercises/${exercise.id}');
      await docRef.putFile(newData['video']);
      item.video = newData['video'];
      newData.remove('video');
    }
    loadingText = 'Обновляем данные';
    notifyListeners();
    await docRef.update(newData);
    if (newData.containsKey('description')){
      item.description = newData['description'];
    }
    notifyListeners();
    return null;
  }

  Future<String?> deleteItem(Exercise exercise,BuildContext context) async {
    loadingText = 'Обновляем тренировки';
    notifyListeners();
    String? result = await Provider.of<TrainingsProvider>(context,listen: false).removeExercise(exercise);
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
    var videoRef = FirebaseStorage.instance.ref('exercises/${exercise.id}');
    var downloadURL = await videoRef.getDownloadURL();
    exercise.video = await fileFromUrl(downloadURL,exercise.id);
  }
}
