import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/program.dart';
import '../../providers/programs_provider.dart';
import '../../widgets/list_items/program_list_item.dart';
import 'package:provider/provider.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});
  static const routeName = '/programs';

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
late List<Program> _programs =[];
  @override
  Widget build(BuildContext context) {
    _programs = Provider.of<ProgramsProvider>(context).items;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_10.jpg'),fit: BoxFit.cover,opacity: 0.5)),
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(backgroundColor: Colors.transparent,automaticallyImplyLeading: false,title: Text('Программы',style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),),),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: CarouselSlider.builder(
                  itemCount: _programs.length,
                  options: CarouselOptions(enlargeCenterPage: true,enlargeFactor: 0.4,viewportFraction: 1,height: MediaQuery.of(context).size.height*0.75,autoPlay: false,enableInfiniteScroll: false),
                  itemBuilder: (ctx, index, i) {
                    return ProgramListItem(_programs[index]);
                  },
                ),
              )
            ]),
          )
        ]),
      ),
    );
  }
}