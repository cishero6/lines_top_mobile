import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lines_top_mobile/helpers/file_from_url.dart';
import 'package:lines_top_mobile/models/lines_top_model.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/db_helper.dart';
import '../helpers/network_connectivity.dart';

class BlogPost extends LinesTopModel{
  @override
  String id = ''; //Идентификатор 
  @override
  String title = '';
  String shortDesc = '';
  String bodyText = '';
  List<File> images = [];
  String date = 'null';
  bool isPrimary = false;
  int version = 0;


  BlogPost.empty(){
    date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  }
  BlogPost({this.id = '',this.title = '',this.shortDesc = '',this.bodyText = '',List<File>? images,String? date,this.version = 0,this.isPrimary = false}){
    this.images = images ?? [];
    this.date = date ?? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  }

  Future<void> fetchMissingFile()async{
    bool internetConnected = await NetworkConnectivity.checkConnection();
    if(!internetConnected) {
      return;
    }
    try{
      String pathsOfImages = '';
      var path =  (await getApplicationDocumentsDirectory()).path;
      for(int i = 0;i < images.length;i++){
        if(!(await images[i].exists())){
          var imageRef = FirebaseStorage.instance.ref('blog/$id/$i');
          var downloadURL = await imageRef.getDownloadURL();
          var tempFile = await fileFromUrl(downloadURL, '${id}_$i'); 
          images[i] = await tempFile.copy('$path/${id}_$i');
        }
        pathsOfImages += '$path/${id}_$i|';
      }
      pathsOfImages = pathsOfImages.substring(0,pathsOfImages.length-1);
      await DBHelper.update('blog_posts',{'id':id,'images': pathsOfImages});      
      print('bl loaded missing');
    }catch(e){
      print('tried to load bl - failed');
      return;
    }
  }

}