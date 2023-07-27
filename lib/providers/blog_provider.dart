import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/file_from_asset.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<List<BlogPost>> fetchAndSetItems([BuildContext? ctx]) async {
    List<Map<String, dynamic>> itemsDB = await DBHelper.getData('blog_posts');

    _items = [];
    var storage = FirebaseStorage.instance;
    var qSnapshot =
        await FirebaseFirestore.instance.collection('blog_posts').get();
    var docs = qSnapshot.docs;
    for (QueryDocumentSnapshot doc in docs) {
      BlogPost blogPost = BlogPost(
          id: doc.id,
          title: doc['title'],
          bodyText: doc['body_text'],
          shortDesc: doc['short_desc'],
          date: doc['date'],
          version: doc['version'],
          );
      if ((itemsDB.indexWhere((element) => element['id'] == blogPost.id) == -1) || (itemsDB.firstWhere((element) => element['id'] == blogPost.id)['version'] != blogPost.version)){
        String downloadURL;
        for (String imageUrl in doc['images']) {
          try {
            downloadURL = await storage.ref(imageUrl).getDownloadURL();
            File file = await fileFromUrl(downloadURL, imageUrl.replaceAll('/', '_'));
            blogPost.images.add(file);
          } catch (e){
            blogPost.images.add(await fileFromAsset('assets/temp/bubbles1.jpeg'));
        }
      }
      _items.add(blogPost);
      String pathsOfImages = '';
      var path = (await getApplicationDocumentsDirectory()).path;
      int index = 0;
      for (var image in blogPost.images){
        image.copy('$path/${blogPost.id}_$index');
        pathsOfImages += '$path/${blogPost.id}_$index|';
        index++;
      }
      DBHelper.insert('blog_posts', {
        'id': blogPost.id,
        'title': blogPost.title,
        'short_desc': blogPost.shortDesc,
        'body_text': blogPost.bodyText,
        'version' : blogPost.version,
        'date': blogPost.date,
        'images': pathsOfImages,
      });

      } else {
       var itemFromDB = itemsDB.firstWhere((element) => element['id'] == blogPost.id);
       List<String> pathsOfImages = (itemFromDB['images'] as String).split('|');
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
    return [..._items];
  }

  Future<void> addPost(BlogPost newPost) async {
    loadingText = 'Создаём пост';
    notifyListeners();
    var collectionReference =
        FirebaseFirestore.instance.collection('blog_posts');
    var querySnapshot = await collectionReference.get();
    var docs = querySnapshot.docs;
    int max = 0;
    for (var element in docs) {
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
      'images': ['null'],
      'version': 0,
    };
    var docReference = collectionReference.doc(newId);
    await docReference.set(mapPost);
    loadingText = 'Загружаем фото 1/${newPost.images.length}';
    notifyListeners();
    var ref =
        FirebaseStorage.instance.ref().child('blog').child(newId).child('main');
    await ref.putFile(newPost.images[0]).whenComplete(() {});
    for (int i = 1; i < newPost.images.length; i++) {
      loadingText = 'Загружаем фото ${i + 1}/${newPost.images.length}';
      notifyListeners();
      ref =
          FirebaseStorage.instance.ref().child('blog').child(newId).child('$i');
      await ref.putFile(newPost.images[i]).whenComplete(() => {});
    }
    loadingText = 'Обновляем пост';
    notifyListeners();
    await docReference.update({
      'images': [
        'blog/$newId/main',
        ...List.generate(
            newPost.images.length - 1, (index) => 'blog/$newId/${index + 1}')
      ],
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
    if (newData.containsKey('id')) {
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
    newData.addEntries({'version': item.version+1}.entries);
    await docRef.update(newData);
    notifyListeners();
    return null;
  }

  Future<void> deleteItem(BlogPost blogPost, [BuildContext? context]) async {
    loadingText = 'Удаляем пост';
    notifyListeners();
    var photoRef = FirebaseStorage.instance.ref('blog/${blogPost.id}/main');
    await photoRef.delete();
    for (int i = 1; i <= blogPost.images.length - 1; i++) {
      photoRef = FirebaseStorage.instance.ref('blog/${blogPost.id}/$i');
      await photoRef.delete();
    }
    var docRef = FirebaseFirestore.instance.doc('blog_posts/${blogPost.id}');
    await docRef.delete();
    _items.removeWhere((element) => element.id == blogPost.id);
    notifyListeners();
    loadingText = '';
  }
}
