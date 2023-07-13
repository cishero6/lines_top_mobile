import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier{
  bool isAuth = false;
  String? userName;
  String? userId;
  String? email;
  bool? paidAccount;
  Map<String,List<int>>? progress;
  List<String>? savedBlogPostIds;

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
      var userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      this.userName = userName;
      this.email = email;
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


  
}