import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/trainings_provider.dart';
import 'package:lines_top_mobile/widgets/list_items/set_blog_item.dart';
import 'package:provider/provider.dart';

import '../../models/training.dart';

class AllSetsScreen extends StatefulWidget {
  const AllSetsScreen({super.key});
  static const routeName = 'blog/all_sets';
  @override
  State<AllSetsScreen> createState() => _AllSetsScreenState();
}

class _AllSetsScreenState extends State<AllSetsScreen> {
  late List<Training> _sets;

  @override
  void initState() {
    _sets = Provider.of<TrainingsProvider>(context,listen: false).items.where((element) => element.isSet).toList();
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
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.2,
                centerTitle: false,
                title: Text(
                'Сеты',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              ),
            ),
            SliverGrid.extent(maxCrossAxisExtent: 300,childAspectRatio: 4/3,children: _sets.map((set) => SetBlogItem(set,width: size.width/(size.width/300).ceil(),)).toList(),),
          ],
        ),
      ),
    );
  }
}