// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/network_connectivity.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:provider/provider.dart';

class UserDataProvider with ChangeNotifier{
  bool isAuth = false;
  String? username;
  String? userId;
  String? email;
  bool? paidAccount;
  Map<String,List<int>>? progress;
  List<String>? statsDates;
  Map<String,List<num>>? statisticts;
  final Stream<User?> _authStateStream = FirebaseAuth.instance.authStateChanges();


  Future<void> setListener()async{
    _authStateStream.listen((event) {
      if(event == null){
        username = null;
        userId = null;
        email = null;
        paidAccount = null;
        progress = null;
        statisticts = null;
        statsDates = null;
        isAuth = false;
        return;
      }
      if(event.uid != ''){
        loadData(event.uid);
      }
    });
  }

  Future<void> _updateProgressIfNeeded(String uid,DocumentReference docRef) async {
    List<Map<String,dynamic>> dataFromDB = await DBHelper.getData('user_data');
    if (dataFromDB.any((userDB) => userDB['id'] == uid)){
      if (dataFromDB.singleWhere((userDB) => userDB['id'] == uid)['needs_upload'] == 1){
        Map<String,List<int>> tempProgress = {};
        Map<String,dynamic> progressFromDBDynamic = dataFromDB.singleWhere((userDB) => userDB['id'] == uid)['progress'] as Map<String,dynamic>;
        for (String prName in progressFromDBDynamic.keys) {
          List<int> temp = [];
          for (int i = 0; i < progressFromDBDynamic[prName].length; i++) {
            temp.add(progressFromDBDynamic[prName][i]);
          }
          tempProgress.addAll({prName: temp});
        }
        try{
          await docRef.update({'progress': tempProgress});
          progress = {...tempProgress};
          await DBHelper.update('user_data', {'id': uid,'needs_upload': 0});
        } on FirebaseException catch (e){
          print(e);
        }
      }
    }
    return;
  }


  Future<bool> loadData(String uid) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return false;
    }
        print('12');

    var docRef = FirebaseFirestore.instance.doc('users/$uid');
    var docSnapshot = await docRef.get();
    var doc = docSnapshot.data()!;
    userId = uid;
    username = doc['username'];
    email = doc['email'];
    paidAccount = doc['paid_account'];
    statisticts = {};
    Map<String,dynamic> statsDynamic = doc['statistics'] as Map<String,dynamic>;
    for(String statName in statsDynamic.keys){
      List<num> temp = [];
      for(int i = 0;i< statsDynamic[statName].length;i++){
        temp.add(statsDynamic[statName][i]);
      }
      statisticts!.addAll({statName: temp});
    }
    statsDates = [];
    var datesDynamic = doc['stats_dates'] as List<dynamic>;
    for (String el in datesDynamic) {
      statsDates!.add(el);
    }
    progress = {};
    Map<String,dynamic> progressDynamic = doc['progress'] as Map<String, dynamic>;
    for (String prName in progressDynamic.keys) {
      List<int> temp = [];
      for (int i = 0; i < progressDynamic[prName].length; i++) {
        temp.add(progressDynamic[prName][i]);
      }
      progress!.addAll({prName: temp});
    }
    await _updateProgressIfNeeded(uid, docRef);
    isAuth  = true;
    notifyListeners();

    return true;
  }

  Future<String> registerUser(String username,String email,String password,{required BuildContext context}) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    UserCredential userCredential;
    try{
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Пользователь с этой почтой уже существует!';
        case 'invalid-email':
          return 'Неверный адрес электронной почты!';
        case 'weak-password':
          return 'Пароль слишком простой!';
        default:
          return 'Что-то пошло не так!';
      }
    }
    var programs = Provider.of<ProgramsProvider>(context,listen: false).items;

    userId = userCredential.user!.uid;
    username = username;
    email = email;
    statisticts = {};
    statsDates = [];
    paidAccount = false;


    progress = {};
    for(var program in programs){
      Map<String,List<int>> temp = {program.id :List.generate(program.trainings.length, (index) => 0)};
      progress!.addAll(temp);
    }


    var docRef = FirebaseFirestore.instance.doc('users/$userId');
    await docRef.set({
      'username' : username,
      'email' : email,
      'progress' : {},
      'statisticts' : {},
      'stats_dates' : [],
      'paid_account' : false,
    });
    isAuth = true;
    notifyListeners();
    return 'Успешно';
  }

  Future<String> loginUser(String email,String password,{required BuildContext context}) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    UserCredential userCredential;
    try{
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          return 'Пользователя с этой почтой не существует!';
        case 'invalid-email':
          return 'Адрес электронной почты некорректно введён!';
        case 'wrong-password':
          return 'Неверный пароль!';
        default:
          return 'Что-то пошло не так!';
      }
    }
    bool result;
    try {
      result = await loadData(userCredential.user!.uid);
    } catch (error){
      print(error);
      await FirebaseAuth.instance.signOut();
      return 'Не удалось загрузить данные пользователя!';
    }
    if (!result){
      await FirebaseAuth.instance.signOut();
      return 'Не удалось загрузить данные пользователя!';
    }
    isAuth = true;
    notifyListeners();
    return 'Успешно!';
  }
  
  Future<String> logoutUser() async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseException catch (error){
      print(error);
      return 'Что-то пошло не так!';
    }
    userId = null;
    username = null;
    email = null;
    paidAccount = null;
    progress = null;
    statisticts = null;
    statsDates = null;
    isAuth = false;

    notifyListeners();
    return 'Успешно!';
  }

  Future<String> changeUsername(String newUsername) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    newUsername = newUsername.trim();
    if(newUsername.length < 4) {
      return 'Имя пользователя слишком короткое!';
    }
    if(newUsername == username){
      return 'Нельзя изменить имя пользователя на текущее!';
    }
    try {
      var userRef = FirebaseFirestore.instance.doc('users/$userId');
      await userRef.update({'username' : newUsername});
    } on FirebaseException catch (e){
      print(e);
      return 'Что-то пошло не так!';
    }
    return 'Успешно!';
  }

  Future<String> changeEmail({required String newEmail,required String password}) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    try{
      AuthCredential authCredential = EmailAuthProvider.credential(email: email!, password: password);
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(authCredential);
      await FirebaseAuth.instance.currentUser!.updateEmail(newEmail);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Пользователь с этой почтой уже существует!';
        case 'invalid-email':
          return 'Адрес электронной почты некорректно введён!';
        case 'wrong-password':
          return 'Неверный пароль!';
        default:
          return 'Что-то пошло не так!';
      }
    }
    email = newEmail;
    try{
    var userRef = FirebaseFirestore.instance.doc('users/$userId');
    await userRef.update({'email' : email});
    } on FirebaseException catch (error){
      print(error);
      return 'Что-то пошло не так!';
    }
    notifyListeners();
    return 'Успешно!';
  }

  Future<String> changePassword(String oldPassword,String newPassword)async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    try{
      AuthCredential authCredential = EmailAuthProvider.credential(
        email: email!,
        password: oldPassword,
      );
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(authCredential);
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      return 'Успешно';
    }on FirebaseAuthException catch(e){
      print(e.code);
      return 'Что-то пошло не так!';
    }
  }


  Future<String> _uploadNewStats()async{
    try{
    var userRef = FirebaseFirestore.instance.doc('users/$userId');
    await userRef.update({'statistics' : statisticts});
    } on FirebaseException catch (error){
      print(error);
      return 'Что-то пошло не так!';
    }
    notifyListeners();
    return 'Успешно!';
  }

  Future<String> updateStatistics(Map<String,List<num>> newStats) async {
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      return 'Отсутвует подключение к интернету!';
    }
    print('??');
    var now = DateTime.now();
    if(statsDates!.isNotEmpty){
      if(statsDates!.last == '${now.day}.${now.month}.${now.year}'){
        for(var statName in statisticts!.keys){
          if(newStats.containsKey(statName)){
            statisticts![statName]!.last = newStats[statName]!.last;
          }
        }
      }
      return await _uploadNewStats();
    }
    statsDates!.add('${now.day}.${now.month}.${now.year}');
    for(var statName in statisticts!.keys){
      if(newStats.containsKey(statName)){
        statisticts![statName]!.add(newStats[statName]!.last);
      }else{
        statisticts![statName]!.add(statisticts![statName]!.last);
      }
    }
    return await _uploadNewStats();
  }



  Future<String> updateProgress(Map<String,List<int>> newProgress) async {
    progress = newProgress;
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected){
      await DBHelper.insert('user_data', {'id': userId!,'needs_upload': 1,'progress': jsonEncode(progress)});
      return 'Отложено!';
    }
    try {
    var userData = FirebaseFirestore.instance.doc('users/$userId');
      await userData.update({'progress' : newProgress});
    } catch (error) {
      print(error);
      return 'Что-то пошло не так!';
    }
    notifyListeners();
    return 'Успешно!';
  }


  Future<void> changeAllVersions() async {
    var exRef = FirebaseFirestore.instance.collection('exercises');
    var blogRef = FirebaseFirestore.instance.collection('blog_posts');
    var prRef = FirebaseFirestore.instance.collection('programs');
    var trRef = FirebaseFirestore.instance.collection('trainings');
    var exercises = (await exRef.get()).docs;
    for(var ex in exercises){
      var ref = exRef.doc(ex.id);
      await ref.update({'version': ex['version']+1});
    }
    var posts = (await blogRef.get()).docs;
    for(var post in posts){
      var ref = blogRef.doc(post.id);
      await ref.update({'version': post['version']+1});
    }
    var programs = (await prRef.get()).docs;
    for(var pr in programs){
      var ref = prRef.doc(pr.id);
      await ref.update({'version': pr['version']+1});
    }
    var trainings = (await trRef.get()).docs;
    for(var tr in trainings){
      var ref = trRef.doc(tr.id);
      await ref.update({'version': tr['version']+1});
    }
  }


  Future<void> deleteStats()async{
    statisticts = {};
    statsDates = [];
    await DBHelper.insert('user_data', {
      'id': userId!,
      'username': username!,
      'email': email!,
      'paid_account': paidAccount! ? 1: 0,
      'progress': jsonEncode(progress),
      'statistics': jsonEncode({}),
      'stats_dates': jsonEncode([]),
    }); 
    var userData = FirebaseFirestore.instance.doc('users/$userId');
    await userData.update({'statistics': {},
          'stats_dates': [],
});
    notifyListeners();
    return;
  }

  
  

  @override 
  String toString() {
    return isAuth ? 
    'AUTH - \n id - $userId \n name - $username \n email - $email \n  progress - $progress \n stats - $statisticts \n dates $statsDates'
    :
    'NOT AUTH';
  }
}