import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

class UserProvider with ChangeNotifier {
  String? username;
  Map<String, List<int>>? progress;
  List<String>? statsDates;
  Map<String, List<num>>? statistics;

  Future<void> initializeData(BuildContext context) async {
        var programs = Provider.of<ProgramsProvider>(context,listen: false).items;
    List<Map<String, dynamic>> dataFromDB = await DBHelper.getData('user_data');
    print(dataFromDB);
    if(dataFromDB.isEmpty){
      print('empty');
      progress = {};
      for (var program in programs){
        progress!.addAll({program.id: List.generate(program.trainings.length, (index) => 0)});
      }
      statistics = {
      'age':<num>[],
      'height':<num>[],
      'weight':<num>[],
      'chest':<num>[],
      'thighs':<num>[],
      'waist':<num>[],
      'activity':<num>[],
    };
                  print(statistics!['age'].runtimeType);

    statsDates = [];
    await DBHelper.insert('user_data', {'id':'0','progress':'{}','statistics': jsonEncode(statistics),'stats_dates':'[]'});
    }else{
      Map<String, List<int>> tempProgress = {};
      Map<String, dynamic> progressFromDBDynamic = jsonDecode(dataFromDB
              .singleWhere((userDB) => userDB['id'] == '0')['progress'])
          as Map<String, dynamic>;
      for (String prName in progressFromDBDynamic.keys) {
        List<int> temp = [];
        for (int i = 0; i < progressFromDBDynamic[prName].length; i++) {
          temp.add(progressFromDBDynamic[prName][i]);
        }
        tempProgress.addAll({prName: temp});
      }
      progress = tempProgress;
      List<dynamic> tempDatesDyn = jsonDecode(dataFromDB
              .singleWhere((userDB) => userDB['id'] == '0')['stats_dates']);
      List<String> tempDates = tempDatesDyn.map((e) => e as String).toList();
      statsDates = tempDates;
      Map<String,List<num>> tempStats = {};
      Map<String,dynamic> tempStatsDynamic = jsonDecode(dataFromDB
              .singleWhere((userDB) => userDB['id'] == '0')['statistics']);
      for (String typeName in tempStatsDynamic.keys) {
        List<num> temp = [];
        for (int i = 0; i < tempStatsDynamic[typeName].length; i++) {
          temp.add(tempStatsDynamic[typeName][i]);
        }
        tempStats.addAll({typeName: temp});
      }
      statistics = tempStats;
      username = dataFromDB.first['username'];
      print('username is $username');
    }
    // ignore: use_build_context_synchronously
    if(programs.length != progress!.keys.length){
      progress = {};
      for (var program in programs){
        progress!.addAll({program.id: List.generate(program.trainings.length, (index) => 0)});
      }
    }
   
  }

    Future<String> setName(String newName) async {
      if(newName.length <3){
        return Future.value('Имя слишком короткое!');
      }
      username = newName;
      await DBHelper.update('user_data', {'id': '0', 'username': '$username'});
      notifyListeners();
      return '';
    }

    Future<String> updateProgress(Map<String, List<int>> newProgress) async {
      String result = '';
      progress = newProgress;
      try {
        await DBHelper.update(
            'user_data', {'id': '0', 'progress': jsonEncode(progress)});
      } catch (e) {
        result = 'Что-то пошло не так!';
      }
      notifyListeners();
      return result;
    }

    Future<String> updateStatistics(Map<String, List<num>> newStats) async {
      var now = DateTime.now();
      if (statsDates!.isNotEmpty) {
        if (statsDates!.last == '${now.day}.${now.month}.${now.year}') {
          for (var statName in statistics!.keys) {
            if (newStats.containsKey(statName)) {
              statistics![statName]!.last = newStats[statName]!.last;
            }
          }
          await DBHelper.update(
            'user_data', {'id': '0', 'statistics': jsonEncode(statistics),'stats_dates': jsonEncode(statsDates)});
          notifyListeners();
          return '';
        }
      }
      statsDates!.add('${now.day}.${now.month}.${now.year}');
      for (var statName in statistics!.keys) {
        if (newStats.containsKey(statName)) {
          statistics![statName]!.add(newStats[statName]!.last);
        } else {
          statistics![statName]!.add(statistics![statName]!.last);
        }
      }
      await DBHelper.update(
            'user_data', {'id': '0', 'statistics': jsonEncode(statistics),'stats_dates': jsonEncode(statsDates)});
      notifyListeners();
      return '';
      
    }

    Future<void> changeAllVersions() async {
      var exRef = FirebaseFirestore.instance.collection('exercises');
      var blogRef = FirebaseFirestore.instance.collection('blog_posts');
      var prRef = FirebaseFirestore.instance.collection('programs');
      var trRef = FirebaseFirestore.instance.collection('trainings');
      var exercises = (await exRef.get()).docs;
      for (var ex in exercises) {
        var ref = exRef.doc(ex.id);
        await ref.update({'version': ex['version'] + 1});
      }
      var posts = (await blogRef.get()).docs;
      for (var post in posts) {
        var ref = blogRef.doc(post.id);
        await ref.update({'version': post['version'] + 1});
      }
      var programs = (await prRef.get()).docs;
      for (var pr in programs) {
        var ref = prRef.doc(pr.id);
        await ref.update({'version': pr['version'] + 1});
      }
      var trainings = (await trRef.get()).docs;
      for (var tr in trainings) {
        var ref = trRef.doc(tr.id);
        await ref.update({'version': tr['version'] + 1});
      }
    }
  }
