import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/file_from_asset.dart';
import '../helpers/file_from_url.dart';
import '../helpers/network_connectivity.dart';
import '../models/program.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import 'trainings_provider.dart';

class ProgramsProvider with ChangeNotifier {
  List<Program> _items = [];
  List<Program> get items {
    return [..._items];
  }

  String loadingText = '';

  Future<bool> fetchAndSetItems(BuildContext context) async {
    var trainings =
        Provider.of<TrainingsProvider>(context, listen: false).items;
    _items = [];
    //1 ЭТАП
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('programs');
    if (itemsDB.isNotEmpty) {
      for (var item in itemsDB) {
        List<String> listOfString = item['trainings'].split('|');
        List<Training> listOfTrainings = [];
        for(String trId in listOfString){
          if(trainings.any((element) => element.id == trId)){
            listOfTrainings.add(trainings.singleWhere((element) => element.id == trId));
          }
        }
        // List<Training> listOfTrainings = listOfString.map((trainingId) => trainings.singleWhere((element) => element.id == trainingId)).toList(); //ИНОГДА ВЫЛЕТ
        File? image1;
        if(!(await File(item['image']).exists())){
          image1 = null;
        }else{
          image1 = File(item['image']);
        }
        _items.add(
          Program(
            id: item['id'],
            title: item['title'],
            subtext: item['subtext'],
            bodyText: item['body_text'],
            image: image1,
            trainings: listOfTrainings,
            isFree: item['is_free']==1,
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
    try{
      var path = (await getApplicationDocumentsDirectory()).path;
      var qSnapshot =
        await FirebaseFirestore.instance.collection('programs')
        .orderBy('priority')
        .get();
      var docs = qSnapshot.docs;
      List<Program> firebaseItems = [];
      for(var docSnapshot in docs){
        var doc = docSnapshot.data();
        List<dynamic> listOfString1 = doc['trainings'];
        List<String> listOfString2 = List<String>.generate(listOfString1.length, (index) => listOfString1[index]);
        List<Training> listOfTrainings = [];
        for(String trId in listOfString2){
          if(trainings.any((element) => element.id == trId)){
            listOfTrainings.add(trainings.singleWhere((element) => element.id == trId));
          }
        }
        //List<Training> listOfTrainings = listOfString2.map((trainingId) => trainings.singleWhere((element) => element.id == trainingId)).toList();
        Program program = Program(
          id: docSnapshot.id,
          title: doc['title'],
          subtext: doc['subtext'],
          bodyText: doc['body_text'],
          trainings: listOfTrainings,
          isFree: doc['is_free'],
          version: doc['version'],
        );
        if((_items.indexWhere((element) => element.id == program.id) == -1) || (_items.singleWhere((element) => element.id == program.id)).version != program.version){
          print('start pr LOAD');
          try{var imageRef = FirebaseStorage.instance.ref('programs/${program.id}');
          var downloadURL = await imageRef.getDownloadURL();
          File tempFile = await fileFromUrl(downloadURL, program.id);
          File file = await tempFile.copy('$path/${program.id}');
          program.image = file;}catch(e){
            print(e);
          }
          firebaseItems.add(program);

          String trainingsArr = '';
          for(var tr in program.trainings){
            trainingsArr += '${tr.id}|';
          }
          trainingsArr = trainingsArr.substring(0,trainingsArr.length-1);
          await DBHelper.insert('programs', {
            'id': program.id,
            'title': program.title,
            'subtext': program.subtext,
            'body_text': program.bodyText,
            'is_free': program.isFree ? 1:0,
            'image': '$path/${program.id}',
            'trainings': trainingsArr,
            'version': program.version
          });
        }else{
          print('start pr EXIST');
          firebaseItems.add(_items.singleWhere((element) => element.id == program.id));
        }
      }
      _items = [...firebaseItems];
    } on FirebaseException catch(e){
      print(e);
      return false;
    }
    return true;

















    
/*
    var storage = FirebaseStorage.instance;
    var qSnapshot = await FirebaseFirestore.instance
        .collection('programs')
        .orderBy('priority')
        .get();
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      Program program = Program(
        id: doc.id,
        title: doc['title'],
        subtext: doc['subtext'],
        bodyText: doc['body_text'],
        version: doc['version'],
      );
      if ((itemsDB.indexWhere((element) => element['id'] == program.id) ==
              -1) ||
          (itemsDB.firstWhere(
                  (element) => element['id'] == program.id)['version'] !=
              program.version)) {
        print('start pr LOAD');
        try {
          var downloadURL =
              await storage.ref(doc['image_url']).getDownloadURL();
          File file = await fileFromUrl(downloadURL, doc.id);
          program.image = file;
        } catch (e) {
          program.image = await fileFromAsset('assets/temp/bubbles1.jpeg');
        }
        var path = (await getApplicationDocumentsDirectory()).path;
        program.image.copy('$path/${program.id}');
        DBHelper.insert('programs', {
          'id': program.id,
          'version': program.version,
          'image': '$path/${program.id}',
        });
      } else {
        print('start pr EXIST');

        var itemFromDB =
            itemsDB.firstWhere((element) => element['id'] == program.id);
        File file = File(itemFromDB['image']);
        program.image = file;
      }
      List<dynamic> listOfString1 = doc['trainings'];
      List<String> listOfString2 = List<String>.generate(
          listOfString1.length, (index) => listOfString1[index]);
      program.trainings = listOfString2
          .map((trainingId) {
              return trainings.singleWhere((element) => element.id == trainingId);})
          .toList();
      _items.add(program);
    }
    */
  }

  Future<void> addProgram(Program newProgram) async {
    loadingText = 'Создаём программу';
    notifyListeners();
    var collectionReference = FirebaseFirestore.instance.collection('programs');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;
    int max = 0;
    for (var element in docs) {
      if (max < int.parse(element.id.split('_').last)) {
        max = int.parse(element.id.split('_').last);
      }
    }
    var newId = 'pr_${max + 1}';
    newProgram.id = newId;
    Map<String, dynamic> mapProgram = {
      'title': newProgram.title,
      'subtext': newProgram.subtext,
      'body_text': newProgram.bodyText,
      'is_free': newProgram.isFree,
      'priority': newId,
      'version': 1,
      'trainings': newProgram.trainings.map((training) => training.id),
      'image_url': 'null',
    };
    var docReference = collectionReference.doc(newId);
    await docReference.set(mapProgram);
    loadingText = 'Загружаем видео';
    notifyListeners();
    final photoRef = FirebaseStorage.instance.ref('programs/$newId');

    await photoRef.putFile(newProgram.image!).whenComplete(() {});
    loadingText = 'Обновляем программу';
    notifyListeners();
    await docReference.update({'image_url': 'programs/$newId'});
    _items.add(newProgram);
    loadingText = 'Обновляем данные';
    notifyListeners();
    var usersData = await FirebaseFirestore.instance.collection('users').get();
    for (var user in usersData.docs) {
      Map<String, List<int>> tempProgress = {};
      var progressDynamic = user.data()['progress'] as Map<String, dynamic>;
      for (String prName in progressDynamic.keys) {
        List<int> temp = [];
        for (int i = 0; i < progressDynamic[prName].length; i++) {
          temp.add(progressDynamic[prName][i]);
        }
        tempProgress.addAll({prName: temp});
      }
      tempProgress.addAll({
        newId: List<int>.generate(newProgram.trainings.length, (index) => 0)
      });
      await FirebaseFirestore.instance
          .doc('users/${user.id}')
          .set({'progress': tempProgress});
    }
    loadingText = '';
    notifyListeners();
  }



  Future<String?> editItem(
      Program program, Map<String, dynamic> newData) async {
    loadingText = 'Обновляем программу';
    notifyListeners();
    var item = _items.singleWhere((element) => element.id == program.id);
    var docRef = FirebaseFirestore.instance.doc('programs/${program.id}');
    if (newData.containsKey('id')) {
      return 'Невозможно изменить документ: нельзя изменять идентификатор';
    }
    if (newData.containsKey('title')) {
      loadingText = 'Проверяем названия';
      notifyListeners();
      var collectionReference =
          FirebaseFirestore.instance.collection('programs');
      var qSnapshot1 = await collectionReference.get();
      var programs = qSnapshot1.docs;
      for (QueryDocumentSnapshot<Map<String, dynamic>> prMap in programs) {
        if (prMap['title'] == newData['title']) {
          return 'Невозможно изменить документ: документ с таким названием уже есть!';
        }
      }
      item.title = newData['title'];
    }
    if (newData.containsKey('image')) {
      loadingText = 'Меняем картинку';
      notifyListeners();
      var docRef = FirebaseStorage.instance.ref('programs/${program.id}');
      await docRef.putFile(newData['image']);
      item.image = newData['image'];
      newData.remove('image');
    }
    loadingText = 'Обновляем данные';
    notifyListeners();
    if (newData.containsKey('subtext')) {
      item.subtext = newData['subtext'];
    }
    if (newData.containsKey('body_text')) {
      item.bodyText = newData['body_text'];
    }
    if (newData.containsKey('trainings')) {
      item.trainings = newData['trainings'];
      newData['trainings'] =
          (newData['trainings'] as List<Training>).map((e) => e.id).toList();
      var usersCollection = FirebaseFirestore.instance.collection('users');
      var usersSnapshot = await usersCollection.get();
      for(var user in usersSnapshot.docs){
        Map<String,dynamic> userProgress = user.data()['progress'];
        userProgress[program.id] = List.generate(newData['trainings'].length, (index) => 0);
        usersCollection.doc(user.id).update({'progress': userProgress});
      }
    }
    newData.addAll({'version': program.version+1});
    await docRef.update(newData);
    notifyListeners();
    return null;
  }

  Future<void> deleteItem(Program program, [BuildContext? context]) async {
    loadingText = 'Удаляем программу';
    notifyListeners();
    var videoRef = FirebaseStorage.instance.ref('programs/${program.id}');
    await videoRef.delete();
    var docRef = FirebaseFirestore.instance.doc('programs/${program.id}');
    await docRef.delete();
    _items.removeWhere((element) => element.id == program.id);

    var usersData = await FirebaseFirestore.instance.collection('users').get();
    for (var user in usersData.docs) {
      Map<String, List<int>> tempProgress = {};
      var progressDynamic = user.data()['progress'] as Map<String, dynamic>;
      for (String prName in progressDynamic.keys) {
        List<int> temp = [];
        for (int i = 0; i < progressDynamic[prName].length; i++) {
          temp.add(progressDynamic[prName][i]);
        }
        tempProgress.addAll({prName: temp});
      }
      tempProgress.remove(program.id);
      await FirebaseFirestore.instance
          .doc('users/${user.id}')
          .update({'progress': tempProgress});
    }
    notifyListeners();
    loadingText = '';
  }

  Future<String?> removeTraining(Training training) async {
    var programsRef = FirebaseFirestore.instance.collection('programs');
    var qSnapshot = await programsRef.get();
    var programs = qSnapshot.docs;
    for (QueryDocumentSnapshot program in programs) {
      if (program['trainings'].contains(training.id) &&
          (program['trainings'].length == 1)) {
        return 'Невозможно удалить: Тренировка является есдинственной в программе ${program['title']}';
      }
    }
    List<String> programsIdsNeedReset = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> program in programs) {
      var doc = program.data();
      if (doc['trainings'].contains(training.id)) {
        doc['trainings'].remove(training.id);
        programsIdsNeedReset.add(program.id);
      }
      await programsRef.doc(program.id).update({'trainings': doc['trainings']});
    }
    for (Program item in _items) {
      item.trainings.removeWhere((element) => element == training);
    }

      await _resetProgramsProgressForEveryone(programsIdsNeedReset);
    return null;
  }



  Future<void> _resetProgramsProgressForEveryone(List<String> programIds)async{
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    var usersData = usersSnapshot.docs; 
    for(var userSnapshot in usersData){
      var newProgress = userSnapshot.data()['progress'];
      for(var prId in programIds){
        newProgress['progress'][prId] = List.generate(items.singleWhere((element) => element.id == prId).trainings.length, (index) => 0);
      }
      await FirebaseFirestore.instance.doc('users/${userSnapshot.id}').update(newProgress);
    }
    return;
  }



  Future<void> compileDatabaseIntoPreload()async{
    List<Map<String,dynamic>> compiledList = [];
    for(var item in items){
      List<String> listOfIds = [];
      for(var tr in item.trainings){
        listOfIds.add(tr.id);
      }
      Map<String,dynamic> mapItem = {
        'id':item.id,
        'title': item.title,
        'subtext': item.subtext,
        'body_text': item.bodyText,
        'trainings': jsonEncode(listOfIds),
        'version': item.version,
      };
      compiledList.add(mapItem);
    }
    await FirebaseFirestore.instance.doc('dev/pre_compiled_data').update({'programs':jsonEncode(compiledList)});
  }

  Future<void> firstLoadItems(BuildContext ctx)async{
    _items = [];
    var trainings = Provider.of<TrainingsProvider>(ctx,listen: false).items;
    var path = (await getApplicationDocumentsDirectory()).path;
    var file = await fileFromAsset('assets/content/programs.txt');
    var fileStr = await file.readAsString();
 List<dynamic> compiledListDynamic = jsonDecode(fileStr);
    List<Map<String, dynamic>> compiledList = [];
    for(var item in compiledListDynamic){
      compiledList.add(item);
    }
         for (Map<String,dynamic> item in compiledList){
      Program program = Program(id: item['id'],title: item['title'],subtext: item['subtext'],bodyText: item['body_text'],version: item['version']);
      List<dynamic> ldynamic = jsonDecode(item['trainings']);
      var lstring = ldynamic.map((e) => e.toString()).toList();
      List<Training> listOfTrainings = lstring.map((trainingId) => trainings.singleWhere((element) => element.id == trainingId)).toList();
      program.trainings = listOfTrainings;

      _items.add(program);
      String trainingsArr = '';

          for(var tr in program.trainings){
            trainingsArr += '${tr.id}|';
          }
          trainingsArr = trainingsArr.substring(0,trainingsArr.length-1);
      await DBHelper.insert('programs', {
            'id': program.id,
            'title': program.title,
            'subtext': program.subtext,
            'body_text': program.bodyText,
            'is_free': program.isFree ? 1:0,
            'image': '$path/${program.id}',
            'trainings': trainingsArr,
            'version': program.version
      });
    }

  }




}
