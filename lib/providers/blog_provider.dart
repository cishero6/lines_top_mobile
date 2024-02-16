import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/file_from_asset.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/network_connectivity.dart';
import '../models/blog_post.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/file_from_url.dart';

class BlogProvider with ChangeNotifier {
  List<BlogPost> _items = [];
  List<BlogPost> get items {
    return [..._items];
  }

  String loadingText = '';

  Future<bool> fetchAndSetItems([BuildContext? ctx]) async {
    _items = [];
    //1 ЭТАП
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('blog_posts');
    if(itemsDB.isNotEmpty){
      for (var item in itemsDB) {
      _items.add(
        BlogPost(
          id: item['id'],
          title: item['title'],
          shortDesc: item['short_desc'],
          bodyText: item['body_text'],
          date: item['date'],
          isPrimary: item['is_primary'] == 1,
          version: item['version'],
        ),
      );
      List<String> pathOfImages = (item['images'] as String).split('|');
      List<File> images = pathOfImages.map((e) => File(e)).toList();
      for (int i=0;i<images.length;i++){
        if(!(await images[i].exists())){
          images.removeAt(i);
        }
      }
        _items.last.images = images;
      }
      
    }
    //2
    var isOnline = await NetworkConnectivity.checkConnection();
    if(itemsDB.isNotEmpty && !isOnline){
      _items.sort((a, b) {
        DateFormat aDF, bDF;
        aDF = DateFormat('dd-MM-yyyy HH:mm');
        bDF = DateFormat('dd-MM-yyyy HH:mm');
        return bDF.parse(b.date).compareTo(aDF.parse(a.date));
    });
      return true;
    }
    if(itemsDB.isEmpty && !isOnline){
      //load assets
      return true;
    }
    //3-4
    try{
      var path = (await getApplicationDocumentsDirectory()).path;
      
      var qSnapshot =
          await FirebaseFirestore.instance.collection('blog_posts').get();
      var docs = qSnapshot.docs;
      var storage = FirebaseStorage.instance;
      List<BlogPost> firebaseItems = [];
      for (var docSnapshot in docs) {
        var doc = docSnapshot.data();
        BlogPost blogPost = BlogPost(
          id: docSnapshot.id,
          title: doc['title'],
          isPrimary: doc['is_primary'],
          shortDesc: doc['short_desc'],
          bodyText: doc['body_text'],
          date: doc['date'],
          version: doc['version'],
        );
        if((_items.indexWhere((element) => element.id == blogPost.id) == -1) || (_items.singleWhere((element) => element.id == blogPost.id)).version != blogPost.version){
          //5
          print('start post LOAD');
          String downloadURL;
          String pathsOfImages = '';
          int index = 0;
          
          for (String imageUrl in doc['images']) {
            try {
              downloadURL = await storage.ref(imageUrl).getDownloadURL();
              File tempFile =
                  await fileFromUrl(downloadURL, imageUrl.replaceAll('/', '_'));
              print('got image');
              File file = await tempFile.copy('$path/${blogPost.id}_$index');
              pathsOfImages += '$path/${blogPost.id}_$index|';
              index++;
              blogPost.images.add(file);
            } catch (e) {
              print('error loading $e');
              blogPost.images
                  .add(await fileFromAsset('assets/images/placeholders/grey_gradient.jpg'));
            }
          }
          if(pathsOfImages.isNotEmpty){
            pathsOfImages = pathsOfImages.substring(0,pathsOfImages.length-1);
          }
          firebaseItems.add(blogPost);
          await DBHelper.insert('blog_posts', {
            'id': blogPost.id,
            'title': blogPost.title,
            'short_desc': blogPost.shortDesc,
            'body_text': blogPost.bodyText,
            'date': blogPost.date,
            'images': pathsOfImages,
            'is_primary': blogPost.isPrimary ? 1:0,
            'version': blogPost.version,
          });
        }else{
          print('start post EXIST');
          firebaseItems.add(_items.singleWhere((element) => element.id == blogPost.id));
        }
      }
      _items = [...firebaseItems];
      _items.sort((a, b) {
        DateFormat aDF, bDF;
        aDF = DateFormat('dd-MM-yyyy HH:mm');
        bDF = DateFormat('dd-MM-yyyy HH:mm');
        return bDF.parse(b.date).compareTo(aDF.parse(a.date));
      });
    } on FirebaseException catch (error) {
      print('blog fetch error $error');
      return false;
    }
    return true;




/*
    for (var doc in docs) {
      BlogPost blogPost = BlogPost(
        id: doc.id,
        title: doc['title'],
        bodyText: doc['body_text'],
        shortDesc: doc['short_desc'],
        date: doc['date'],
        version: doc['version'],
      );
      if ((itemsDB.indexWhere((element) => element['id'] == blogPost.id) ==
              -1) ||
          (itemsDB.firstWhere(
                  (element) => element['id'] == blogPost.id)['version'] !=
              blogPost.version)) {
        String downloadURL;
        
        _items.add(blogPost);
        String pathsOfImages = '';
        var path = (await getApplicationDocumentsDirectory()).path;
        int index = 0;
        for (var image in blogPost.images) {
          image.copy('$path/${blogPost.id}_$index');
          pathsOfImages += '$path/${blogPost.id}_$index|';
          index++;
        }
        DBHelper.insert('blog_posts', {
          'id': blogPost.id,
          'version': blogPost.version,
          'images': pathsOfImages,
        });
      } else {
        print('start post exist');
        var itemFromDB =
            itemsDB.firstWhere((element) => element['id'] == blogPost.id);
        List<String> pathsOfImages =
            (itemFromDB['images'] as String).split('|');
        pathsOfImages.removeLast();
        List<File> tempImages = pathsOfImages.map((e) => File(e)).toList();
        blogPost.images = [...tempImages];
        _items.add(blogPost);
      }
    }
    _items.sort((a, b) {
      DateFormat aDF, bDF;
      aDF = DateFormat('dd-MM-yyyy HH:mm');
      bDF = DateFormat('dd-MM-yyyy HH:mm');
      return bDF.parse(b.date).compareTo(aDF.parse(a.date));
    });
    return true;
*/
  }

  Future<void> addPost(BlogPost newPost) async {
    loadingText = 'Создаём пост';
    notifyListeners();
    var collectionReference =
        FirebaseFirestore.instance.collection('blog_posts');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;
    int max = 0;


    for (var element in docs) { //MAKING NEW ID
      if (max < int.parse(element.id.split('_').last)) {
        max = int.parse(element.id.split('_').last);
      }
    }
    var newId = 'post_${max + 1}';
    newPost.id = newId;
    Map<String, dynamic> mapPost = {
      'title': newPost.title,
      'short_desc': newPost.shortDesc,
      'body_text': newPost.bodyText,
      'date': newPost.date,
      'is_primary': newPost.isPrimary,
      'images': ['null'],
      'version': 0,
    };


    var docReference = collectionReference.doc(newId); //LOADING IMAGES TO FIREBASE
    await docReference.set(mapPost);
    var ref =
        FirebaseStorage.instance.ref().child('blog').child(newId).child('0');
    for (int i = 0; i < newPost.images.length; i++) {
      loadingText = 'Загружаем фото ${i + 1}/${newPost.images.length}';
      notifyListeners();
      ref =
          FirebaseStorage.instance.ref().child('blog').child(newId).child('$i');
      await ref.putFile(newPost.images[i]).whenComplete(() => {});
    }


    loadingText = 'Обновляем пост';
    notifyListeners();
    await docReference.update({ //UPDATING IMAGES INFO
      'images': [
        ...List.generate(
            newPost.images.length, (index) => 'blog/$newId/$index')
      ],
    });


    var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
    String pathsOfImages = '';
    int index = 0;
    for(var image in newPost.images){
      image = await image.copy('$path/${newPost.id}_$index');
      pathsOfImages += '$path/${newPost.id}_$index|';
      index++;
    }
    pathsOfImages  = pathsOfImages.substring(0,pathsOfImages.length-1);



    await DBHelper.insert('blog_posts', { //INSERT NEW POST IN DATABASE
      'id': newPost.id,
      'title': newPost.title,
      'body_text': newPost.bodyText,
      'short_desc': newPost.shortDesc,
      'is_primary': newPost.isPrimary ?1:0,
      'date': newPost.date,
      'images': pathsOfImages,
      'version': newPost.version
    });


    loadingText = '';
    notifyListeners();
    _items.insert(0, newPost);
    notifyListeners();
  }

  Future<String?> editItem(
      BlogPost blogPost, Map<String, dynamic> newData) async {
    loadingText = 'Обновляем пост';
    notifyListeners();
    var item = _items.singleWhere((element) => element.id == blogPost.id);
    var docRef = FirebaseFirestore.instance.doc('blog_posts/${blogPost.id}');

    if (newData.containsKey('id')) { //ПРОВЕРКА СМЕНЫ ПОЛЕЙ
      return 'Невозможно изменить документ: нельзя изменять идентификатор';
    }
    if (newData.containsKey('title')) {
      loadingText = 'Проверяем названия';
      notifyListeners();
      var collectionReference =
          FirebaseFirestore.instance.collection('blog_posts');
      var qSnapshot1 = await collectionReference.get();
      var posts = qSnapshot1.docs;
      for (QueryDocumentSnapshot<Map<String, dynamic>> postMap in posts) {
        if (postMap['title'] == newData['title']) {
          return 'Невозможно изменить документ: документ с таким названием уже есть!';
        }
      }
      item.title = newData['title'];
    }
    loadingText = 'Обновляем данные';
    notifyListeners();
    if (newData.containsKey('short_desc')) {
      item.shortDesc = newData['short_desc'];
    }
    if (newData.containsKey('body_text')) {
      item.bodyText = newData['body_text'];
    }
    if(newData.containsKey('is_primary')){
      item.isPrimary = newData['is_primary'];
    }
        String pathsOfImages = '';
    if (newData.containsKey('images')) {
      item.images = [];
      loadingText = 'Обновляем фотографии';
      notifyListeners();
      Reference ref;
      List<String> refImages = [];
      for (int i = 0; i < newData['images'].length; i++) {
        loadingText =
            'Обновляем фотографии ${i + 1}/${newData['images'].length}';
        notifyListeners();
        ref = FirebaseStorage.instance.ref('blog/${item.id}/$i');
        await ref.putFile(newData['images'][i]);
        item.images.add(newData['images'][i]);
        refImages.add('blog/${item.id}/$i');
      }
      newData['images'] = refImages;
      var path = (await getApplicationDocumentsDirectory()).path; //COPY FILES IN DOCUMENTS
    int index = 0;
    for(var image in item.images){
      image = await image.copy('$path/${item.id}_$index');
      pathsOfImages += '$path/${item.id}_$index|';
    }
    pathsOfImages  = pathsOfImages.substring(0,pathsOfImages.length-1);


    }
    newData.addEntries({'version': item.version + 1}.entries);
    item.version++;
    await docRef.update(newData);
    

    newData['images'] = pathsOfImages;

    await DBHelper.insert('blog_posts', { //INSERT EDITED POST IN DATABASE
      'id': item.id,
      'title': item.title,
      'body_text': item.bodyText,
      'short_desc': item.shortDesc,
      'is_primary': item.isPrimary ? 1:0,
      'date': item.date,
      'images': pathsOfImages,
      'version': item.version
    });


    loadingText = '';
    notifyListeners();
    return null;
  }

  Future<void> deleteItem(BlogPost blogPost, [BuildContext? context]) async {
    loadingText = 'Удаляем пост';
    notifyListeners();
    var photoRef = FirebaseStorage.instance.ref('blog/${blogPost.id}/0');
    for (int i = 0; i <= blogPost.images.length - 1; i++) {
      photoRef = FirebaseStorage.instance.ref('blog/${blogPost.id}/$i');
      await photoRef.delete();
    }
    var docRef = FirebaseFirestore.instance.doc('blog_posts/${blogPost.id}');
    await docRef.delete();
    _items.removeWhere((element) => element.id == blogPost.id);
    notifyListeners();
    loadingText = '';
  }

  

  Future<void> compileDatabaseIntoPreload()async{
    List<Map<String,dynamic>> compiledList = [];
    for(var item in items){
      Map<String,dynamic> mapItem = {
        'id':item.id,
        'title': item.title,
        'date': item.date,
        'short_desc': item.shortDesc,
        'body_text': item.bodyText,
        'images_count': item.images.length,
        'version': item.version,
        'is_primary': item.isPrimary,
      };
      compiledList.add(mapItem);
    }
    await FirebaseFirestore.instance.doc('dev/pre_compiled_data').update({'blog_posts':jsonEncode(compiledList)});
  }

    Future<void> firstLoadItems() async {
    _items = [];
    var file = await fileFromAsset('assets/content/blog_posts.txt');
    var fileStr = await file.readAsString();
    List<dynamic> compiledListDynamic = jsonDecode(fileStr);
    List<Map<String, dynamic>> compiledList = [];
    for(var item in compiledListDynamic){
      compiledList.add(item);
    }
     

    for (Map<String, dynamic> item in compiledList) {
      BlogPost blogPost = BlogPost(
          id: item['id'],
          title: item['title'],
          shortDesc: item['short_desc'],
          bodyText: item['body_text'],
          date: item['date'],
          version: item['version'],
          isPrimary: item['is_primary'],
          );
          String pathsOfImages = '';

      _items.add(blogPost);
      await DBHelper.insert('blog_posts', {
            'id': blogPost.id,
            'title': blogPost.title,
            'short_desc': blogPost.shortDesc,
            'body_text': blogPost.bodyText,
            'date': blogPost.date,
            'images': pathsOfImages,
            'is_primary': blogPost.isPrimary ? 1:0,
            'version': blogPost.version,
      });
    }
  }
  
}
