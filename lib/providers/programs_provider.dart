import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/file_from_asset.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/file_from_url.dart';
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

  Future<List<Program>> fetchAndSetItems(BuildContext context) async {
    _items = [];
    var trainings =
        Provider.of<TrainingsProvider>(context, listen: false).items;
    var itemsDB = await DBHelper.getData('programs');
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
          'title': program.title,
          'subtext': program.subtext,
          'body_text': program.bodyText,
          'version': program.version,
          'image': '$path/${program.id}',
        });
        print('end pr LOAD');
      } else {
        print('start pr EXIST');

        var itemFromDB =
            itemsDB.firstWhere((element) => element['id'] == program.id);
        File file = File(itemFromDB['image']);
        program.image = file;
        print('end pr EXIST');
      }

      List<dynamic> listOfString1 = doc['trainings'];
      List<String> listOfString2 = List<String>.generate(
          listOfString1.length, (index) => listOfString1[index]);
      program.trainings = listOfString2
          .map((trainingId) =>
              trainings.singleWhere((element) => element.id == trainingId))
          .toList();
      _items.add(program);
    }
    return [..._items];
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

    await photoRef.putFile(newProgram.image).whenComplete(() {});
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

  Future<void> addProgramFromMap(Map<String, dynamic> map) async {}
  Future<void> addProgramFromMapWithLink(Map<String, dynamic> map) async {}

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
          .set({'progress': tempProgress});
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
    for (QueryDocumentSnapshot<Map<String, dynamic>> program in programs) {
      var doc = program.data();
      if (doc['trainings'].contains(training.id)) {
        doc['trainings'].remove(training.id);
      }
      await programsRef.doc(program.id).update({'trainings': doc['trainings']});
    }
    for (Program item in _items) {
      item.trainings.removeWhere((element) => element == training);
    }
    return null;
  }
}
