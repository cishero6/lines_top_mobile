import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/blog_post.dart';
import '../../screens/details_screens/blog_post_details_screen.dart';
import '../../screens/more_screens.dart/all_posts_screen.dart';

// ignore: must_be_immutable
class SecondaryBlogItem extends StatefulWidget {

  late BlogPost? blogPost = null;
  late String? title;
  late String? subtext;
  final double? width;


  SecondaryBlogItem(this.blogPost,{this.width,super.key});
  SecondaryBlogItem.empty(this.title,this.subtext,{this.width,super.key});

  @override
  State<SecondaryBlogItem> createState() => _SecondaryBlogItemState();
}

class _SecondaryBlogItemState extends State<SecondaryBlogItem> {
  final GlobalKey _backgroundImageKey = GlobalKey();
  late String title;
  late String subtext;
  late File? image;
  late void Function() onTap;

  @override
  void initState() {
    if(widget.blogPost != null){
      title = widget.blogPost!.title;
      subtext = widget.blogPost!.shortDesc;
      onTap = () => Navigator.of(context).pushNamed(BlogPostDetailsScreen.routeName,arguments: [widget.blogPost]);
    } else {
      title = widget.title!;
      subtext = widget.subtext!;
      onTap = ()=> Navigator.of(context).pushNamed(AllPostsScreen.routeName);
    }
    super.initState();
  }


Widget _buildParallaxBackground(BuildContext context) {
  return widget.blogPost != null ? ConstrainedBox(constraints: const BoxConstraints.tightFor(width: double.infinity),child: FadeInImage(imageErrorBuilder: (context, error, stackTrace) {
              widget.blogPost!.fetchMissingFile();
              return Image.asset(
                'assets/images/placeholders/grey_gradient.jpg',fit: BoxFit.cover,);
            },placeholder: const AssetImage('assets/images/placeholders/grey_gradient.jpg'), image: (widget.blogPost!.images.isEmpty ? AssetImage('assets/content/blog_posts/${widget.blogPost!.id}_0') : FileImage(widget.blogPost!.images.first)) as ImageProvider,key: _backgroundImageKey,fit: BoxFit.cover)) : Container(key: _backgroundImageKey,decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black,Color.fromARGB(255, 105, 105, 105)],begin: Alignment.topLeft,end: Alignment.bottomRight)),height: 300,);
    /*return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
        isHorizontal: true
      ),
      children: [
        if(widget.blogPost != null) FadeInImage(placeholder: const AssetImage('assets/images/placeholders/grey_gradient.jpeg'), image: FileImage(widget.blogPost!.images.first),key: _backgroundImageKey,fit: BoxFit.cover,),
        //if(widget.blogPost != null) Image.file(widget.blogPost!.images.first,key: _backgroundImageKey,fit: BoxFit.cover,),
        if(widget.blogPost == null) Container(key: _backgroundImageKey,decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black,Color.fromARGB(255, 105, 105, 105)],begin: Alignment.topLeft,end: Alignment.bottomRight)),height: 300,),
      ],
    );*/
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 15,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: widget.width != null ? widget.width!-50 : null,
            child: Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            _buildParallaxBackground(context),
            _buildGradient(),
            _buildTitleAndSubtitle(),
          ]),
        ),
      ),
    );
  }
}