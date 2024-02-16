import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/file_from_url.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/db_helper.dart';
import '../helpers/file_from_asset.dart';
import '../helpers/network_connectivity.dart';
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

  Future<bool> fetchAndSetItems(
      BuildContext ctx) async {
     _items = [];
    //1 ЭТАП
    var exercises = Provider.of<ExercisesProvider>(ctx,listen: false).items;
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('trainings');
    if (itemsDB.isNotEmpty) {
      for (var item in itemsDB) {
        //REFORMATTING LIST<DYNAMIC> TO LIST<EXERCISE>
        Map<String, List<Exercise>> doneSections = {};
        Map<String, dynamic> dynamicSections = jsonDecode(item['sections']);
        Map<String, List<String>> stringSections = dynamicSections.map((key, value) => MapEntry(key,List<String>.generate(value.length, (index) => value[index])));
        for(var sectionName in stringSections.keys){
          List<Exercise> list = [];
          for(var exId in stringSections[sectionName]!){
            if(exercises.any((element) => element.id == exId)){
              list.add(exercises.singleWhere((element) => element.id == exId));
            }
          }
          doneSections.addAll({sectionName: list});
        }
        //doneSections = stringSections.map((sectionName, listOfExercises) => MapEntry(sectionName,listOfExercises.map((ex) => exercises.firstWhere((element) => element.id == ex)).toList()));
        
          //REFORMATTING LIST OF REPSIDS TO LIST<INT>
        Map<String, dynamic> dynamicExReps = jsonDecode(item['ex_repetitions_ids']); //MAYBE ONE LINE
        Map<String, List<int>> doneExReps = dynamicExReps.map((key, value) => MapEntry(key,List<int>.generate(value.length, (index) => value[index])));
      File? image1;
        if(item['image'] == 'null'){
          image1 = null;
        }else{
          if(!(await File(item['image']).exists())){
            image1 = null;
          }else{
            image1 = File(item['image']);
          }
        }
        //ADDING ITEM
        _items.add(Training(
          id: item['id'],
            title: item['title'],
            sections: doneSections,
            exRepetitionsIds: doneExReps,
            isSet: item['is_set'] == 1,
            description: item['description'] == 'null' ? null : item['description'],
            image: image1,
            version: item['version'],
          )
        );
      }
    }
    //2
    var isOnline = await NetworkConnectivity.checkConnection();
    if (itemsDB.isNotEmpty && !isOnline) {
      print(_items);
      return true;
    }
    if (itemsDB.isEmpty && !isOnline) {
      //load assets
      return true;
    }
    //3
    try{
      var qSnapshot =
          await FirebaseFirestore.instance.collection('trainings').orderBy('priority').get();
      var docs = qSnapshot.docs;
      
      List<Training> firebaseItems = [];
      for(var docSnapshot in docs){
        var doc = docSnapshot.data();
        Map<String, dynamic> dynamicSections = doc['sections'];
        Map<String, List<String>> stringSections = dynamicSections.map((key, value) => MapEntry(key,List<String>.generate(value.length, (index) => value[index])));
        Map<String, List<Exercise>> doneSections = stringSections.map((sectionName, listOfExercises) => MapEntry(sectionName,listOfExercises.map((ex) => exercises.firstWhere((element) => element.id == ex)).toList()));

        Map<String, dynamic> dynamicExReps = doc['ex_repetitions_ids'];
        Map<String, List<int>> doneExReps = dynamicExReps.map((key, value) => MapEntry(key,List<int>.generate(value.length, (index) => value[index])));

        Training training = Training(
          id: docSnapshot.id,
          title: doc['title'],
          description: doc['description'] == 'null' ? null : doc['description'],
          version: doc['version'],
          isSet: doc['is_set'],
          sections: doneSections,
          exRepetitionsIds: doneExReps,
        );
        if(!training.isSet){ //IF SET DONT EVEN CHECK TO DOWNLOAD
          Map<String,List<String>> dbMapSections = {};
          for(var section in training.sections.keys){
            dbMapSections.addAll({section: training.sections[section]!.map((e) => e.id).toList()});
          }
          await DBHelper.insert('trainings', {
            'id': training.id,
            'title': training.title,
            'description': 'null',
            'image': 'null',
            'sections': jsonEncode(dbMapSections),
            'ex_repetitions_ids': jsonEncode(training.exRepetitionsIds),
            'is_set': training.isSet ? 1:0,
            'version': training.version,
          });
          firebaseItems.add(training);
          continue;
        }
        if((_items.indexWhere((element) => element.id == training.id) == -1) || (_items.singleWhere((element) => element.id == training.id)).version != training.version){
          //5
          print('start training LOAD');
          print(training.id);
          var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
          try{String downloadURL = await FirebaseStorage.instance.ref(doc['image']).getDownloadURL();;
          File tempFile = await fileFromUrl(downloadURL, 'trainings_${training.id}');
          training.image = await tempFile.copy('$path/${training.id}');} catch(E){
            print(E);
          }
          firebaseItems.add(training);
          Map<String,List<String>> dbMapSections = {};
          for(var section in training.sections.keys){
            dbMapSections.addAll({section: training.sections[section]!.map((e) => e.id).toList()});
          }
          print('$path/${training.id}');
          await DBHelper.insert('trainings', {
            'id': training.id,
            'title': training.title,
            'description': training.description ?? 'null',
            'image': '$path/${training.id}',
            'sections': jsonEncode(dbMapSections),
            'ex_repetitions_ids': jsonEncode(training.exRepetitionsIds),
            'is_set': training.isSet ? 1:0,
            'version': training.version,
          });
        }else{
          print('start training EXIST');
          firebaseItems.add(_items.singleWhere((element) => element.id == training.id));
        }
      }
      _items = [...firebaseItems];
    } on FirebaseException catch (e) {
      print(e);
      return false;
    }
    return true;
/*
    _items = [];
    var qSnapshot =
        await FirebaseFirestore.instance.collection('trainings').get(); 
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Training training = Training(
        id: doc.id,
        title: doc['title'],
        description: doc['description'],
        version: doc['version'],
      );

      
      _items.add(training);
    }
    notifyListeners();
    return [..._items];
    */
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
        'ex_repetitions_ids': newTraining.exRepetitionsIds,
        'description': newTraining.description ?? 'null',
        'is_set': newTraining.isSet,
        'version': 1,
        'image': 'null'
    },
    );
    Map<String,List<Exercise>> tempMap = {};
    for(String sectionName in newTraining.sections.keys){
      tempMap.addAll({'${sectionName}_${keyOrder.indexOf(sectionName)}' : newTraining.sections[sectionName]!});
    }
    newTraining.sections = tempMap;
    if(newTraining.isSet){
      final imageRef = FirebaseStorage.instance.ref('trainings/$newId');
      await imageRef.putFile(newTraining.image!).whenComplete(() {});
      await collectionReference.doc(newId).update({'image':'trainings/$newId'});
    }
    _items.add(newTraining);
    notifyListeners();
  }

  Future<String?> editItem(Training training,Map<String,dynamic> newData,List<String> keyOrder) async {
  loadingText = 'Обновляем тренировку';
  notifyListeners();
  var item = _items.singleWhere((element) => element.id == training.id);
  var path = (await getApplicationDocumentsDirectory()).path;

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
    if (newData.containsKey('image')) {
      loadingText = 'Меняем фото';
      notifyListeners();
      var docRef = FirebaseStorage.instance.ref('trainings/${item.id}');
      await docRef.putFile(newData['image']);
      item.image = newData['image'];
      newData.remove('image');
      newData['image'] = 'trainings/${item.id}';
      item.image = await item.image!.copy('$path/${item.id}');//COPY FILE IN DOCUMENTS

    }
    if (newData.containsKey('description')){
      item.description = newData['description'];
    }
    if (newData.containsKey('sections')){
      Map<String,List<Exercise>> tempMap = {};
      for(String sectionName in newData['sections'].keys){
        tempMap.addAll({'${sectionName}_${keyOrder.indexOf(sectionName)}' : newData['sections'][sectionName]!});
      }
      item.sections = tempMap;

      newData['sections'] = (newData['sections'] as Map<String,List<Exercise>>).map((key, value) => MapEntry('${key}_${keyOrder.indexOf(key)}', value.map((e) => e.id).toList()));
      item.exRepetitionsIds = newData['ex_repetitions_ids'];
    }
    await docRef.update(newData);

    await DBHelper.update('trainings', { //INSERT EDITED TRAININGS IN DATABASE
      'id': item.id,
      'title': item.title,
      'description': item.description ?? 'null',
      'is_set': item.isSet? 1:0,
      'image': item.image == null ? 'null' : '$path/${item.id}',
      'version': item.version,
      if(newData.containsKey('sections')) 'sections': jsonEncode(newData['sections']),
      if(newData.containsKey('sections')) 'ex_repetitions_ids': jsonEncode(newData['ex_repetitions_ids']),
    });
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
    if(training.isSet){
    var refFile = FirebaseStorage.instance.ref('trainings/${training.id}');
    await refFile.delete();
    }


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
      // for(List<dynamic> section in data['sections'].values){
      //   if (section.contains(exercise.id)) {
      //     section.removeWhere((element) => element == exercise.id);
      //   }
      // }
      for(String sectionName in data['sections'].keys){
        if (data['sections'][sectionName].contains(exercise.id)) {
          for(int i = data['sections'][sectionName].length-1;i>=0;i--){
            if(data['sections'][sectionName][i].id == exercise.id){
              (data['sections'][sectionName] as List<Exercise>).removeAt(i);
              (data['ex_repetitions_ids'][sectionName] as List<int>).removeAt(i);
            }
          }
        }
      }
      await trainingsRef.doc(training.id).update({'sections': data['sections'],'ex_repetitions_ids': data['ex_repetitions_ids']});
    }
    for(Training item in _items){
      for(String sectionName in item.sections.keys){
        if (item.sections[sectionName]!.contains(exercise)) {
          for(int i =item.sections[sectionName]!.length-1;i>=0;i--){
            if(item.sections[sectionName]![i].id == exercise.id){
              (item.sections[sectionName] as List<Exercise>).removeAt(i);
              (item.exRepetitionsIds[sectionName] as List<int>).removeAt(i);
            }
          }
        }
      }
      // for(List<Exercise> section in item.sections.values){
      //   section.removeWhere((element) => element == exercise);
      // }
    }
    return null;
  }



Future<void> compileDatabaseIntoPreload()async{
    List<Map<String,dynamic>> compiledList = [];
    for(var item in items){
      Map<String,List<String>> sectionsMapIds = {};
      for(var sectionName in item.sections.keys){
        List<String> temp = [];
        for(var ex in item.sections[sectionName]!){
          temp.add(ex.id);
        }
        sectionsMapIds.addAll({sectionName:temp});
      }
      Map<String,dynamic> mapItem = {
        'id':item.id,
        'title': item.title,
        'description': item.description ?? 'null',
        'is_set': item.isSet,
        'sections': jsonEncode(sectionsMapIds),
        'ex_repetitions_ids': jsonEncode(item.exRepetitionsIds),
        'version': item.version,
      };
      compiledList.add(mapItem);
    }
    await FirebaseFirestore.instance.doc('dev/pre_compiled_data').update({'trainings':jsonEncode(compiledList)});
  }




  Future<void> firstLoadItems(BuildContext ctx)async{
  _items = [];
  var exercises = Provider.of<ExercisesProvider>(ctx,listen: false).items;
  var path = (await getApplicationDocumentsDirectory()).path;
    var file = await fileFromAsset('assets/content/trainings.txt');
  var fileStr = await file.readAsString();
    List<dynamic> compiledListDynamic = jsonDecode(fileStr);
    List<Map<String, dynamic>> compiledList = [];
    for(var item in compiledListDynamic){
      compiledList.add(item);
    }
       for (Map<String,dynamic> item in compiledList){

    Training training = Training(id: item['id'],title: item['title'],version: item['version'],isSet: item['is_set'],description: item['description'] == 'null' ? null : item['description']);
        Map<String, dynamic> dynamicSections = jsonDecode(item['sections']);;
        Map<String, List<String>> stringSections = dynamicSections.map((key, value) => MapEntry(key,List<String>.generate(value.length, (index) => value[index])));
        Map<String, List<Exercise>> doneSections = stringSections.map((sectionName, listOfExercises) => MapEntry(sectionName,listOfExercises.map((ex) => exercises.firstWhere((element) => element.id == ex)).toList()));
    training.sections = doneSections;


        Map<String, dynamic> dynamicExReps = jsonDecode(item['ex_repetitions_ids']);
        Map<String, List<int>> doneExReps = dynamicExReps.map((key, value) => MapEntry(key,List<int>.generate(value.length, (index) => value[index])));

    training.exRepetitionsIds = doneExReps;
    _items.add(training);
    Map<String,List<String>> dbMapSections = {};
          for(var section in training.sections.keys){
            dbMapSections.addAll({section: training.sections[section]!.map((e) => e.id).toList()});
          }
     await DBHelper.insert('trainings', {
            'id': training.id,
            'title': training.title,
            'description': training.description ?? 'null',
            'image': '$path/${training.id}',
            'sections': jsonEncode(dbMapSections),
            'ex_repetitions_ids': jsonEncode(training.exRepetitionsIds),
            'is_set': training.isSet ? 1:0,
            'version': training.version,
    });
  }
}

Future<void> doShit()async{
  var trainings = await FirebaseFirestore.instance.collection('trainings').get();
  for (var training in trainings.docs){
    var id = training.id;
    await FirebaseFirestore.instance.doc('trainings/$id').update({'priority': id});
  }
  print('done');
}
}


