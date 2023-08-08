import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';

class UserDataProvider with ChangeNotifier{
  bool isAuth = false;
  String? userName;
  String? userId;
  String? email;
  bool? paidAccount;
  Map<String,List<int>>? progress;
  List<String>? savedBlogPostIds;



  Future<bool> checkAuth() async {
    if(FirebaseAuth.instance.currentUser == null){
      return Future.value(true);
    }
    var userData = await DBHelper.getData('user_data');
    userId = userData.first['id'];
    userName = userData.first['username'];
    email = userData.first['email'];
    paidAccount = (userData.first['paid_account'] == 1);
    progress = jsonDecode(userData.first['progress']);
    savedBlogPostIds = jsonDecode(userData.first['saved_posts']);
    isAuth = true;
    return true;
  }

  Future<bool> addSavedId(String newId)async {
    List<String> temp = [...savedBlogPostIds!];
    temp.add(newId);
    var userData = FirebaseFirestore.instance.doc('users/$userId');
    try {
      await userData.update({'saved_posts': temp});
      savedBlogPostIds!.add(newId);
      notifyListeners();
      return true;
    } catch(e){
      print(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeSavedId(String newId)async {
    List<String> temp = [...savedBlogPostIds!];
    temp.remove(newId);
    var userData = FirebaseFirestore.instance.doc('users/$userId');
    try {
      await userData.update({'saved_posts': temp});
      savedBlogPostIds!.remove(newId);
      notifyListeners();
      return true;
    } catch(e){
      print(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress(Map<String,List<int>> newProgress,{required BuildContext context}) async {
    progress = newProgress;
    var userData = FirebaseFirestore.instance.doc('users/$userId');
    try {
      await userData.update({'progress' : newProgress});
    } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> registerUser(String userName,String email,String password,{required BuildContext context}) async {
      try {
      var usersListRef = FirebaseFirestore.instance.doc('dev_collection/usernames');
      List<dynamic> usersList = (await usersListRef.get()).data()!['list'];
      if(usersList.contains(userName.trim())){
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).clearSnackBars();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Такое имя пользователя уже используется')));
        return false;
      }
      var userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      this.userName = userName.trim();
      this.email = email.trim();
      userId = userCredentials.user!.uid;
      paidAccount = false;
      var programs = await FirebaseFirestore.instance.collection('programs').get();
      var programsNames = programs.docs.map((e) => e.id).toList();
      progress = {};
      for(int i = 0;i<programsNames.length;i++){
        Map<String,List<int>> temp = {programsNames[i]:List.generate(programs.docs[i].data()['trainings'].length, (index) => 0)};
        progress!.addAll(temp);
      }
      var usersCollection = FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(userCredentials.user!.uid).set({
        'email' : this.email,
        'user_name': this.userName,
        'paid_account': false,
        'progress': progress,
        'saved_posts': [],
      });
      usersList.add(this.userName);
      usersListRef.update({'list': usersList});
      isAuth = true;
      savedBlogPostIds = [];
      notifyListeners();

      return true;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
        return false;
      }
  }

   Future<bool> loginUser(String email,String password,{required BuildContext context}) async {
    try{
      var userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).get();
      var userData = userSnapshot.data()!;
      userId = userCredentials.user!.uid;
      this.email = userData['email'];
      paidAccount = userData['paid_account'];
      userName = userData['user_name'];
      var savedDynamic = userData['saved_posts'] as List<dynamic>;
      savedBlogPostIds = [];
      for(String el in savedDynamic){
        savedBlogPostIds!.add(el);
      }
      Map<String,List<int>> tempProgress = {};
      var progressDynamic = userData['progress'] as Map<String,dynamic>;
      for(String prName in progressDynamic.keys){
        List<int> temp = [];
        for(int i=0;i < progressDynamic[prName].length;i++){
          temp.add(progressDynamic[prName][i]);
        }
        tempProgress.addAll({prName: temp});
      }
      progress = tempProgress;
      isAuth = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e){
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
        notifyListeners();
        return false;
    }
   }

   Future<bool> logoutUser()async{
    try{
     await FirebaseAuth.instance.signOut();
     isAuth = false;
     userId = null;
     userName = null;
     progress = null;
     email = null;
     notifyListeners();
     return true;

    }catch(e){
      print(e);
      return false;
    }

   }

  Future<String> changeUsername(String newUsername) async {
    newUsername = newUsername.trim();
    if(newUsername.length < 4) {
      return 'Имя пользователя слишком короткое';
    }
    if(newUsername == userName){
      return 'Нельзя изменить имя пользователя на текущее';
    }
    try {
      var usersListRef = FirebaseFirestore.instance.doc('dev_collection/usernames');
      List<dynamic> usersList = (await usersListRef.get()).data()!['list'];
      if(usersList.contains(newUsername)){
        return 'Пользователь с таким именем уже существует';
      }
      var userRef = FirebaseFirestore.instance.doc('users/$userId');
      await userRef.update({'user_name' : newUsername});
    } on FirebaseException catch (e){
      return e.toString();
    }
    return 'Успешно';
  }


  Future<void> changeAllVersions() async {
    var exRef = FirebaseFirestore.instance.collection('exercises');
    var blogRef = FirebaseFirestore.instance.collection('blog_posts');
    var prRef = FirebaseFirestore.instance.collection('programs');
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
  }
  
}