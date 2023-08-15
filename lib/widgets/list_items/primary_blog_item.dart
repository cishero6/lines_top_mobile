import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/parallax_flow_delegate.dart';
import 'package:lines_top_mobile/screens/details_screens/blog_post_details_screen.dart';

import '../../models/blog_post.dart';

class PrimaryBlogItem extends StatefulWidget {
  final BlogPost blogPost;
  final GlobalKey scrollableKey;
  const PrimaryBlogItem(this.blogPost,{required this.scrollableKey,super.key});

  @override
  State<PrimaryBlogItem> createState() => _PrimaryBlogItemState();
}

class _PrimaryBlogItemState extends State<PrimaryBlogItem> {

    final GlobalKey _backgroundImageKey = GlobalKey();



Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(widget.scrollableKey.currentContext!),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey
      ),
      children: [Image.file(
        widget.blogPost.images.first,
        key: _backgroundImageKey,
        fit: BoxFit.cover,
      ),]
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.blogPost.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.height*0.32,
            child: Text(
              widget.blogPost.shortDesc,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
      onTap: ()=>Navigator.of(context).pushNamed(BlogPostDetailsScreen.routeName,arguments: [widget.blogPost]),
      child: AspectRatio(
        aspectRatio: 4/3,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
                children: [
                  _buildParallaxBackground(context),
                  _buildGradient(),
                  _buildTitleAndSubtitle(),
                ],
              ),
          ),
        ),
      ),
    );
  }
}