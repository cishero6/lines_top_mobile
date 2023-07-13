import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import '../models/exercise.dart';
import './exercises_provider.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';

class TrainingsProvider with ChangeNotifier {
  List<Training> _items = [];
  List<Training> get items {
    return [..._items];
  }
  String loadingText = '';

  Future<List<Training>> fetchAndSetItems(BuildContext context) async {
    var exercises = Provider.of<ExercisesProvider>(context,listen: false).items;
    _items = [];
    var qSnapshot =
        await FirebaseFirestore.instance.collection('trainings').get();
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Training training = Training(
        id: doc.id,
        title: doc['title'],
      );
      Map<String,dynamic> sections = doc['sections'];
      Map<String,List<String>> sections1 = sections.map((key, value) => MapEntry(key, List<String>.generate(value.length, (index) => value[index])));
      training.sections = sections1.map(
        (sectionName, listOfExercises) => MapEntry(
          sectionName,
          listOfExercises
              .map(
                (ex) => exercises.firstWhere((element) => element.id == ex),
              )
              .toList(),
        ),
      );

      _items.add(training);
    }
    notifyListeners();
    return [..._items];
  }

  Future<void> addTraining(Training newTraining,List<String> keyOrder) async {
    var collectionReference =
        FirebaseFirestore.instance.collection('trainings');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;
    int max = 0;
    for (var element in docs) {
      if (max < int.parse(element.id.split('_').last)) {
        max = int.parse(element.id.split('_').last);
      }
    }
    var newId = 'tr_${max + 1}';
    newTraining.id = newId;
    await collectionReference.doc(newId).set(
      {
        'title': newTraining.title,
        'sections': newTraining.sections.map((sectionName, listOfExercises) => MapEntry('${sectionName}_${keyOrder.indexOf(sectionName)}', listOfExercises.map((ex) => ex.id))),
    },
    );
    Map<String,List<Exercise>> tempMap = {};
    for(String sectionName in newTraining.sections.keys){
      tempMap.addAll({'${sectionName}_${keyOrder.indexOf(sectionName)}' : newTraining.sections[sectionName]!});
    }
    newTraining.sections = tempMap;
    _items.add(newTraining);
    notifyListeners();
  }

  Future<void> addProgramFromMap(Map<String, dynamic> map,List<String> keyOrder) async {
    Training newTraining = Training(
          title: map['title'],
          sections: map['sections'],
        );
    await addTraining(newTraining,keyOrder);
  }

  Future<void> addProgramFromMapWithLink(Map<String, dynamic> map,List<String> keyOrder,BuildContext context) async {
    var exercises = Provider.of<ExercisesProvider>(context,listen: false).items;
    Training newTraining = Training(title: map['title']);
    newTraining.sections = (map['sections'] as Map<String, List<String>>).map(
        (sectionName, listOfExercises) => MapEntry(
          sectionName,
          listOfExercises
              .map(
                (ex) => exercises.firstWhere((element) => element.id == ex),
              )
              .toList(),
        ),
      );
    await addTraining(newTraining,keyOrder);
  }

  Future<String?> editItem(Training training,Map<String,dynamic> newData,List<String> keyOrder) async {
  loadingText = 'Обновляем тренировку';
  notifyListeners();
  var item = _items.singleWhere((element) => element.id == training.id);
    var docRef = FirebaseFirestore.instance.doc('trainings/${training.id}');
    if(newData.containsKey('id')){
      return 'Невозможно изменить документ: нельзя изменять идентификатор';
    }
    if(newData.containsKey('title')){
        loadingText = 'Проверяем названия';
        notifyListeners();
      var collectionReference = FirebaseFirestore.instance.collection('trainings');
      var qSnapshot1 = await collectionReference.get();
      var trainings = qSnapshot1.docs;
       for(QueryDocumentSnapshot<Map<String, dynamic>> trMap in trainings){
        if (trMap['title'] == newData['title']){
          return 'Невозможно изменить документ: документ с таким названием уже есть!';
        }
      }
      item.title = newData['title'];
    }
    loadingText = 'Обновляем данные';
    notifyListeners();
    if (newData.containsKey('sections')){
      Map<String,List<Exercise>> tempMap = {};
      for(String sectionName in newData['sections'].keys){
        tempMap.addAll({'${sectionName}_${keyOrder.indexOf(sectionName)}' : newData['sections'][sectionName]!});
      }
      item.sections = tempMap;

      newData['sections'] = (newData['sections'] as Map<String,List<Exercise>>).map((key, value) => MapEntry('${key}_${keyOrder.indexOf(key)}', value.map((e) => e.id).toList()));
    }
    await docRef.update(newData);
    notifyListeners();
    return null;
  }


  Future<String?> deleteItem(Training training,BuildContext context) async {
    loadingText = 'Обновляем программы';
    notifyListeners();
    String? result = await Provider.of<ProgramsProvider>(context,listen: false).removeTraining(training);
    if(result != null) return result;
    loadingText = 'Удаляем тренировку';
    notifyListeners();
    var docRef = FirebaseFirestore.instance.doc('trainings/${training.id}');
    await docRef.delete();
    _items.removeWhere((element) => element.id == training.id);
    // ignore: use_build_context_synchronously
    notifyListeners();
    loadingText = '';
    return null;
  }

  Future<String?> removeExercise(Exercise exercise)async {
    var trainingsRef = FirebaseFirestore.instance.collection('trainings');
    var qSnapshot = await trainingsRef.get();
    var trainings = qSnapshot.docs;
    for(QueryDocumentSnapshot training in trainings){
      for(List<dynamic> section in training['sections'].values){
        if(section.contains(exercise.id) && (section.length == 1)){
          return 'Невозможно удалить: Упражнение является есдинственный в одной из секций тренировки ${training['title']}';
        }
      }
    }
    for(QueryDocumentSnapshot<Map<String,dynamic>> training in trainings){
      var data = training.data();
      for(List<dynamic> section in data['sections'].values){
        if (section.contains(exercise.id)) {
          section.removeWhere((element) => element == exercise.id);
        }
      }
      await trainingsRef.doc(training.id).update({'sections': data['sections']});
    }
    for(Training item in _items){
      for(List<Exercise> section in item.sections.values){
        section.removeWhere((element) => element == exercise);
      }
    }
    return null;
  }
}
