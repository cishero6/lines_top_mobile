import 'package:flutter/material.dart';
import '../../providers/blog_provider.dart';
import '../../providers/trainings_provider.dart';
import '../../widgets/list_items/primary_blog_item.dart';
import '../../widgets/list_items/set_blog_item.dart';
import 'package:provider/provider.dart';

import '../../models/blog_post.dart';
import '../../models/training.dart';
import '../../widgets/list_items/secondary_blog_item.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});
  static const routeName = '/blog';
  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final GlobalKey _key = GlobalKey();

  late List<BlogPost> _primaryPosts;
  late List<BlogPost> _secondaryPosts;
  late List<Training> _sets;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    var size =MediaQuery.of(context).size;
    _sets = Provider.of<TrainingsProvider>(context, listen: false)
        .items
        .where((element) => element.isSet)
        .toList();
    _primaryPosts = Provider.of<BlogProvider>(context, listen: false)
        .items
        .where((element) => element.isPrimary)
        .toList();
    _secondaryPosts = Provider.of<BlogProvider>(context, listen: false)
        .items
        .where((element) => !element.isPrimary)
        .toList();


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
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              title: Text(
                'Главная',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
            SliverToBoxAdapter(
              key: _key,
              child: SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) => PrimaryBlogItem(
                    _primaryPosts[index],
                    scrollableKey: _key,
                    width: 260*4/3,
                  ),
                  itemCount: _primaryPosts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(
                thickness: 6,
                color: Colors.black26,
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Новости',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold,color:Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SliverGrid(
                delegate: SliverChildListDelegate(
                  [
                  if(_secondaryPosts.length>3) ..._secondaryPosts.sublist(0,3).map((e) => SecondaryBlogItem(e,width: size.width/(size.width/600).ceil())).toList(),
                  if(_secondaryPosts.length<=3) ..._secondaryPosts.map((e) => SecondaryBlogItem(e,width: size.width/(size.width/600).ceil())).toList(),
                  SecondaryBlogItem.empty('Больше новостей', ''),
                  ]
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600, mainAxisExtent: 100)),
            //SliverList.list(children: _secondaryPosts.sublist(0,4).map((e) => SecondaryBlogItem(e)).toList()),
            const SliverToBoxAdapter(
              child: Divider(
                thickness: 6,
                color: Colors.black26,
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Лучшие сеты',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold,color:Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SliverGrid(
                delegate: SliverChildListDelegate(
                  [
                    if(_sets.isNotEmpty) ..._sets.sublist(0,5).map((e) => SetBlogItem(e,width: size.width/(size.width/600).ceil(),)).toList(),
                    SetBlogItem.empty('Все сеты', '',),
                  ]),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600, childAspectRatio: 4 / 3)),
          ],
        ),
      ),
    );
  }
}
