import 'dart:io';

import 'package:intl/intl.dart';
import 'package:lines_top_mobile/models/lines_top_model.dart';

class BlogPost extends LinesTopModel{
  @override
  String id = ''; //Идентификатор 
  @override
  String title = '';
  String shortDesc = '';
  String bodyText = '';
  List<File> images = [];
  String date = 'null';
  int version = 0;


  BlogPost.empty(){
    date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  }
  BlogPost({this.id = '',this.title = '',this.shortDesc = '',this.bodyText = '',List<File>? images,String? date,this.version = 0}){
    this.images = images ?? [];
    this.date = date ?? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  }

}