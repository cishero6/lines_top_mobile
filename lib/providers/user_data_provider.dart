// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lines_top_mobile/helpers/db_helper.dart';
// import 'package:lines_top_mobile/helpers/network_connectivity.dart';
// import 'package:lines_top_mobile/helpers/phone_auth_status.dart';
// import 'package:lines_top_mobile/providers/programs_provider.dart';
// import 'package:lines_top_mobile/providers/verification_id_provider.dart';
// import 'package:provider/provider.dart';

// class UserDataProvider with ChangeNotifier{
//   bool isAuth = false;
//   String? username;
//   String? userId;
//   String? phoneNumber;
//   bool? paidAccount;
//   Map<String,List<int>>? progress;
//   List<String>? statsDates;
//   Map<String,List<num>>? statistics;
//   final Stream<User?> _authStateStream = FirebaseAuth.instance.authStateChanges();




//   Future<void> setListener()async{
//     _authStateStream.listen((event) {
//       if(event == null){
//         username = null;
//         userId = null;
//         phoneNumber = null;
//         paidAccount = null;
//         progress = null;
//         statistics = null;
//         statsDates = null;
//         isAuth = false;
//         return;
//       }
//       if(event.uid != ''){
//         loadData(event.uid);
//       }
//     });
//   }

//   Future<void> _updateProgressIfNeeded(String uid,DocumentReference docRef) async {
//     List<Map<String,dynamic>> dataFromDB = await DBHelper.getData('user_data');
//     if (dataFromDB.any((userDB) => userDB['id'] == uid)){
//       if (dataFromDB.singleWhere((userDB) => userDB['id'] == uid)['needs_upload'] == 1){
//         print('Надо обновить!!');
//         Map<String,List<int>> tempProgress = {};
//         Map<String,dynamic> progressFromDBDynamic = jsonDecode(dataFromDB.singleWhere((userDB) => userDB['id'] == uid)['progress'])  as Map<String,dynamic>;
//         for (String prName in progressFromDBDynamic.keys) {
//           List<int> temp = [];
//           for (int i = 0; i < progressFromDBDynamic[prName].length; i++) {
//             temp.add(progressFromDBDynamic[prName][i]);
//           }
//           tempProgress.addAll({prName: temp});
//         }
//         try{
//           await docRef.update({'progress': tempProgress});
//           progress = {...tempProgress};
//           await DBHelper.update('user_data', {'id': uid,'needs_upload': 0});
//           print('updated');
//         } on FirebaseException catch (e){
//           print(e);
//         }
//       }
//     }
//     return;
//   }


//   Future<bool> loadData(String uid) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected) {
//       return false;
//     }
//     var docRef = FirebaseFirestore.instance.doc('users/$uid');
//     var docSnapshot = await docRef.get();
//     if(!docSnapshot.exists){
//       return false;
//     }
//     var doc = docSnapshot.data()!;
//     userId = uid;
//     username = doc['username'];
//     phoneNumber = doc['phone_number'];
//     paidAccount = doc['paid_account'];
//     statistics = {};
//     Map<String,dynamic> statsDynamic = doc['statistics'] as Map<String,dynamic>;
//     for(String statName in statsDynamic.keys){
//       List<num> temp = [];
//       for(int i = 0;i< statsDynamic[statName].length;i++){
//         temp.add(statsDynamic[statName][i]);
//       }
//       statistics!.addAll({statName: temp});
//     }
//     statsDates = [];
//     var datesDynamic = doc['stats_dates'] as List<dynamic>;
//     for (String el in datesDynamic) {
//       statsDates!.add(el);
//     }
//     progress = {};
//     Map<String,dynamic> progressDynamic = doc['progress'] as Map<String, dynamic>;
//     for (String prName in progressDynamic.keys) {
//       List<int> temp = [];
//       for (int i = 0; i < progressDynamic[prName].length; i++) {
//         temp.add(progressDynamic[prName][i]);
//       }
//       progress!.addAll({prName: temp});
//     }
//     await _updateProgressIfNeeded(uid, docRef);
//     isAuth  = true;
//     notifyListeners();

//     return true;
//   }

//   @Deprecated('no longer using email') 
//   Future<String> registerUser(String username,String email,String password,{required BuildContext context}) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     UserCredential userCredential;
//     try{
//       userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
//     } on FirebaseAuthException catch (error) {
//       switch (error.code) {
//         case 'email-already-in-use':
//           return 'Пользователь с этой почтой уже существует!';
//         case 'invalid-email':
//           return 'Неверный адрес электронной почты!';
//         case 'weak-password':
//           return 'Пароль слишком простой!';
//         default:
//           return 'Что-то пошло не так!';
//       }
//     }
//     var programs = Provider.of<ProgramsProvider>(context,listen: false).items;

//     userId = userCredential.user!.uid;
//     username = username;
//     email = email;
//     statistics = {};
//     statsDates = [];
//     paidAccount = false;


//     progress = {};
//     for(var program in programs){
//       Map<String,List<int>> temp = {program.id :List.generate(program.trainings.length, (index) => 0)};
//       progress!.addAll(temp);
//     }


//     var docRef = FirebaseFirestore.instance.doc('users/$userId');
//     await docRef.set({
//       'username' : username,
//       'email' : email,
//       'progress' : {},
//       'statistics' : {},
//       'stats_dates' : [],
//       'paid_account' : false,
//     });
//     isAuth = true;
//     notifyListeners();
//     return 'Успешно!';
//   }


//   Future<String> verifyPhoneNumber(String phoneNumber,{required BuildContext ctx})async{
//     print('start ver');
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     String result = '';
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     await FirebaseAuth.instance.verifyPhoneNumber(phoneNumber: phoneNumber,verificationCompleted: (_){}, verificationFailed: (error){
//       print(error);
//       result = 'Что-то пошло не так!';
//       return;
//     }, codeSent: (verificationId,_){
//       print('set id');
//       Provider.of<VerificationIdProvider>(ctx,listen: false).setVerificationId(verificationId);
//       phoneAuthStatus = 3;
//       return;
//     }, codeAutoRetrievalTimeout:(_){});
//     return result;
//   }


//   Future<String> phoneSignInUser(String verificationId,String code,String username,{required BuildContext context})async{
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     UserCredential userCredential;
//     try{
//       userCredential = await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code));
//     } on FirebaseAuthException catch (error) {
//       switch (error.code) {
//         case 'invalid-verification-code':
//           return 'Неверный код!';
//         default:
//           phoneAuthStatus = 2;
//           return 'Что-то пошло не так!';
//       }
//     }
//     var docSnapshot = await FirebaseFirestore.instance
//         .doc('users/${userCredential.user!.uid}')
//         .get();
//     if (!docSnapshot.exists) {
//       await _initializeData(context: context, userId: userCredential.user!.uid, username: username,phoneNumber: userCredential.user!.phoneNumber);
//     } 

//     isAuth = true;
//     notifyListeners();
//     phoneAuthStatus = 0;
//     return 'Успешно!';
//   }

//   Future<String> _initializeData({required BuildContext context,required String userId,required String username,String? phoneNumber}) async {
//     var programs = Provider.of<ProgramsProvider>(context,listen: false).items;

//     this.userId = userId;
//     this.username = username;
//     this.phoneNumber = phoneNumber;
//     statistics = {
//       'age':[],
//       'height':[],
//       'weight':[],
//       'chest':[],
//       'thighs':[],
//       'waist':[],
//       'activity':[],
//     };
//     statsDates = [];
//     paidAccount = false;

//     progress = {};
//     for(var program in programs){
//       Map<String,List<int>> temp = {program.id :List.generate(program.trainings.length, (index) => 0)};
//       progress!.addAll(temp);
//     }

//     var docRef = FirebaseFirestore.instance.doc('users/$userId');
//     try{
//     await docRef.set({
//       'username' : username,
//       'phone_number' : phoneNumber,
//       'progress' : progress,
//       'statistics' : statistics,
//       'stats_dates' : [],
//       'paid_account' : false,
//     });
//     } on FirebaseException catch(e){
//       print(e);
//       return 'Что-то пошло не так!';
//     }

//     return 'Успешно!';
//   }





//   @Deprecated('no longer using email') 
//   Future<String> loginUser(String email,String password,{required BuildContext context}) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     UserCredential userCredential;
//     try{
//       userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
//     } on FirebaseAuthException catch (error) {
//       switch (error.code) {
//         case 'user-not-found':
//           return 'Пользователя с этой почтой не существует!';
//         case 'invalid-email':
//           return 'Адрес электронной почты некорректно введён!';
//         case 'wrong-password':
//           return 'Неверный пароль!';
//         default:
//           return 'Что-то пошло не так!';
//       }
//     }
//     bool result;
//     try {
//       result = await loadData(userCredential.user!.uid);
//     } catch (error){
//       print(error);
//       await FirebaseAuth.instance.signOut();
//       return 'Не удалось загрузить данные пользователя!';
//     }
//     if (!result){
//       await FirebaseAuth.instance.signOut();
//       return 'Не удалось загрузить данные пользователя!';
//     }
//     isAuth = true;
//     notifyListeners();
//     return 'Успешно!';
//   }
  
//   Future<String> logoutUser() async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     try {
//       await FirebaseAuth.instance.signOut();
//     } on FirebaseException catch (error){
//       print(error);
//       return 'Что-то пошло не так!';
//     }
//     userId = null;
//     username = null;
//     phoneNumber = null;
//     paidAccount = null;
//     progress = null;
//     statistics = null;
//     statsDates = null;
//     isAuth = false;

//     notifyListeners();
//     return 'Успешно!';
//   }

//   Future<String> changeUsername(String newUsername) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     newUsername = newUsername.trim();
//     if(newUsername == username){
//       return 'Нельзя изменить имя пользователя на текущее!';
//     }
//     if(newUsername.length < 4) {
//       return 'Имя пользователя слишком короткое!';
//     }
//     try {
//       var userRef = FirebaseFirestore.instance.doc('users/$userId');
//       await userRef.update({'username' : newUsername});
//       username = newUsername;
//     } on FirebaseException catch (e){
//       print(e);
//       return 'Что-то пошло не так!';
//     }
//     return 'Успешно!';
//   }

//   @Deprecated('no longer using email') 
//   Future<String> changeEmail({required String newEmail,required String password}) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     try{
//       AuthCredential authCredential = EmailAuthProvider.credential(email: '', password: password);
//       await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(authCredential);
//       await FirebaseAuth.instance.currentUser!.updateEmail(newEmail);
//     } on FirebaseAuthException catch (error) {
//       switch (error.code) {
//         case 'email-already-in-use':
//           return 'Пользователь с этой почтой уже существует!';
//         case 'invalid-email':
//           return 'Адрес электронной почты некорректно введён!';
//         case 'wrong-password':
//           return 'Неверный пароль!';
//         default:
//           return 'Что-то пошло не так!';
//       }
//     }
//     phoneNumber = newEmail;
//     try{
//     var userRef = FirebaseFirestore.instance.doc('users/$userId');
//     await userRef.update({'email' : 'null'});
//     } on FirebaseException catch (error){
//       print(error);
//       return 'Что-то пошло не так!';
//     }
//     notifyListeners();
//     return 'Успешно!';
//   }

//   @Deprecated('no longer using email') 
//   Future<String> changePassword(String oldPassword,String newPassword)async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     try{
//       AuthCredential authCredential = EmailAuthProvider.credential(
//         email: '',
//         password: oldPassword,
//       );
//       await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(authCredential);
//       await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
//       return 'Успешно';
//     }on FirebaseAuthException catch(e){
//       print(e.code);
//       return 'Что-то пошло не так!';
//     }
//   }


//   Future<String> _uploadNewStats()async{
//     try{
//     var userRef = FirebaseFirestore.instance.doc('users/$userId');
//     await userRef.update({'statistics' : statistics,'stats_dates':statsDates});
//     } on FirebaseException catch (error){
//       print(error);
//       return 'Что-то пошло не так!';
//     }
//     notifyListeners();
//     return 'Успешно!';
//   }

//   Future<String> updateStatistics(Map<String,List<num>> newStats) async {
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     print('??');
//     var now = DateTime.now();
//     if(statsDates!.isNotEmpty){
//       if(statsDates!.last == '${now.day}.${now.month}.${now.year}'){
//         for(var statName in statistics!.keys){
//           if(newStats.containsKey(statName)){
//             statistics![statName]!.last = newStats[statName]!.last;
//           }
//         }
//         return await _uploadNewStats();
//       }
//     }
//     statsDates!.add('${now.day}.${now.month}.${now.year}');
//     for(var statName in statistics!.keys){
//       if(newStats.containsKey(statName)){
//         statistics![statName]!.add(newStats[statName]!.last);
//       }else{
//         statistics![statName]!.add(statistics![statName]!.last);
//       }
//     }
//     return await _uploadNewStats();
//   }



//   Future<String> updateProgress(Map<String,List<int>> newProgress) async {
//     progress = newProgress;
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       await DBHelper.insert('user_data', {'id': userId!,'needs_upload': 1,'progress': jsonEncode(progress)});
//       print('ОТложено!!');
//     notifyListeners();
//     return 'Отложено!';

//     }
//     try {
//     var userData = FirebaseFirestore.instance.doc('users/$userId');
//       await userData.update({'progress' : newProgress});
//     } catch (error) {
//       print(error);
//       return 'Что-то пошло не так!';
//     }
//     notifyListeners();
//     return 'Успешно!';
//   }


//   Future<void> changeAllVersions() async {
//     var exRef = FirebaseFirestore.instance.collection('exercises');
//     var blogRef = FirebaseFirestore.instance.collection('blog_posts');
//     var prRef = FirebaseFirestore.instance.collection('programs');
//     var trRef = FirebaseFirestore.instance.collection('trainings');
//     var exercises = (await exRef.get()).docs;
//     for(var ex in exercises){
//       var ref = exRef.doc(ex.id);
//       await ref.update({'version': ex['version']+1});
//     }
//     var posts = (await blogRef.get()).docs;
//     for(var post in posts){
//       var ref = blogRef.doc(post.id);
//       await ref.update({'version': post['version']+1});
//     }
//     var programs = (await prRef.get()).docs;
//     for(var pr in programs){
//       var ref = prRef.doc(pr.id);
//       await ref.update({'version': pr['version']+1});
//     }
//     var trainings = (await trRef.get()).docs;
//     for(var tr in trainings){
//       var ref = trRef.doc(tr.id);
//       await ref.update({'version': tr['version']+1});
//     }
//   }


//   Future<void> deleteStats()async{
//     statistics = {};
//     statsDates = [];
//     var userData = FirebaseFirestore.instance.doc('users/$userId');
//     await userData.update({
//       'statistics': {},
//       'stats_dates': [],
//     });
//     notifyListeners();
//     return;
//   }

//   Future<bool> doesUserExist(String phoneNumber)async{
//     var users = await FirebaseFirestore.instance.collection('users').get();
//     for(var userSnapshot in users.docs){
//       if(userSnapshot.data()['phone_number'] == phoneNumber){
//         return true;
//       }
//     }
//     return false;
//   }


//   Future<String> deleteUser(AuthCredential newAuthCredential)async{
//     bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       return 'Отсутвует подключение к интернету!';
//     }
//     try{
//       await FirebaseFirestore.instance.doc('users/$userId').delete();
//       await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(newAuthCredential);
//       await FirebaseAuth.instance.currentUser!.delete();
//       return 'Успешно!';
//     } on FirebaseException catch(e){
//       switch (e.code) {
//         case 'invalid-verification-code':
//           return 'Неверный код!';
//         default:
//           return 'Что-то пошло не так!!';
//       }
//     } catch (otherError){
//       print(otherError.toString());
//       return 'Что-то очень пошло не так!';
//     }
//   }

  
//   Future<String> dev()async{
//     var exs= await FirebaseFirestore.instance.collection('exercises').get();
//     for(var ex in exs.docs){
//       var doc = ex.data();
//       await FirebaseFirestore.instance.doc('exercises/${ex.id}').update({'exercise_list_texts': [doc['exercise_list_text'],'','','',''],'repetition_list_texts':[doc['repetition_list_text'],'','','','']});
//     }
//     var trainings = await FirebaseFirestore.instance.collection('trainings').get();

//     for(var tr in trainings.docs){
//       var doc = tr.data();
//       Map<String,List<int>> temp_reps = {};
//       for(var sectionName in doc['sections'].keys){
//         temp_reps[sectionName.split('_').first] = List.generate(doc['sections'][sectionName].length, (index) => 0);
//       }
//       await FirebaseFirestore.instance.doc('trainings/${tr.id}').update({'ex_repetitions_ids':temp_reps});
//     }
//     return 'Успешно';
//   }
  

//   @override 
//   String toString() {
//     return !isAuth ? 
//     'AUTH - \n id - $userId \n name - $username \n phone - $phoneNumber \n  progress - $progress \n stats - $statistics \n dates $statsDates'
//     :
//     'NOT AUTH';
//   }
// }