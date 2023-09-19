import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:lines_top_mobile/widgets/list_items/primary_blog_item.dart';
import 'package:provider/provider.dart';

import '../../models/blog_post.dart';

class AllPostsScreen extends StatefulWidget {
  const AllPostsScreen({super.key});
  static const routeName = 'blog/all_posts';
  @override
  State<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  late List<BlogPost> _blogPosts;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    _blogPosts = Provider.of<BlogProvider>(context,listen: false).items;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 90, 90, 90)
          ], begin: Alignment.bottomLeft, end: Alignment.topRight),
          //image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_3.jpg'),fit: BoxFit.cover,opacity: 0.5),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              key: _key,
              backgroundColor: Colors.transparent,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.2,
                centerTitle: false,
                title: Text(
                'Новости',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              ),
            ),
            SliverGrid.extent(maxCrossAxisExtent: 600,childAspectRatio: 4/3,children: _blogPosts.map((post) => PrimaryBlogItem(post, scrollableKey: _key,width: size.width/(size.width/600).ceil(),)).toList(),),
          ],
        ),
      ),
    );
  }
}