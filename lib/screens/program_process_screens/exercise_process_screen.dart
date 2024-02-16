// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/section_name_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/all_sets_screen.dart';
import 'package:lines_top_mobile/widgets/list_items/exercise_carousel_item.dart';
import 'package:provider/provider.dart';
import '../../models/training.dart';

import '../../providers/user_provider.dart';
import '../../widgets/exercises_carousel.dart';

class ExerciseProcessScreen extends StatefulWidget {
  final Training training;  
  final String initialSection;
  final String? programId;
  final int? trainingIndex;
  const ExerciseProcessScreen(this.training, this.initialSection, {this.programId,this.trainingIndex,super.key});
  static const routeName = '/trainings_list/sections_list/exercise_process';
  @override
  State<ExerciseProcessScreen> createState() => _ExerciseProcessScreenState();
}

class _ExerciseProcessScreenState extends State<ExerciseProcessScreen> {
  late ExercisesCarousel exCarousel;
  late AppBar appBar;
  List<Map<String, dynamic>> _orderedExercises = [];
  late bool _isSet;
  late Future<bool> Function() _onEndTraining;

  final List<Widget> _backgrounds = [1, 2, 3, 4]
      .map((e) => ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: Image.asset(
            'assets/images/backgrounds/ex_$e.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(1),
          )))
      .toList();

  

  Future<bool> _onWillPop() async {
    Map<String,List<int>> curProgress = {...Provider.of<UserProvider>(context,listen: false).progress!};
    curProgress[widget.programId]![widget.trainingIndex!] = (exCarousel.currentIndex / _orderedExercises.length * 100).round();
    Provider.of<UserProvider>(context,listen: false).updateProgress(curProgress);
    return true;
  }

  @override
  void initState() {
    Provider.of<SectionNameProvider>(context, listen: false)
        .initiateSectionName(widget.initialSection);
    var orderedKeys = widget.training.sections.keys.toList()
      ..sort((a, b) => a.split('_').last.compareTo(b.split('_').last));
    for (int i = 0; i < orderedKeys.length; i++) {
      for (int j = 0;j < widget.training.sections[orderedKeys[i]]!.length;j++) {
          print(widget.training.sections[orderedKeys[i]]);
          print(widget.training.exRepetitionsIds);
        _orderedExercises.add({
          orderedKeys[i]: widget.training.sections[orderedKeys[i]]![j],
          'rep_id': widget.training.exRepetitionsIds[orderedKeys[i].split('_').first]![j]
        });
      }
    }
    if(widget.programId == null && widget.trainingIndex == null){
      _isSet = true;
    }else{
      _isSet = false;
    }
    if (_isSet) {
      _onEndTraining = () {
        Navigator.of(context).pushReplacementNamed(AllSetsScreen.routeName);
        return Future.value(true);
        };
    } else {
      _onEndTraining = () async{
        await _onWillPop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return true;
      };
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
        appBar = AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                Provider.of<SectionNameProvider>(context)
                    .sectionName
                    .split('_')
                    .first,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              ),
            );
    int initialIndex;
    int keyIndex = 0;
    initialIndex = _orderedExercises.indexWhere((element) => element.keys.first == widget.initialSection);
    exCarousel = ExercisesCarousel(
      skipHeight: appBar.preferredSize.height+40,
      initialIndex: initialIndex,
                onEndTraining: _onEndTraining,
                items: _orderedExercises
                    .map((e) => ExerciseCarouselItem(e.values.first,key: ValueKey(keyIndex++),repId: e['rep_id'],))
                    .toList(),
                sectionNames: _orderedExercises.map((e) => e.keys.first).toList(),
              );
    return WillPopScope(
      onWillPop: _onEndTraining,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: appBar,
        body:  Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: SizedBox(
                  key: ValueKey(Provider.of<SectionNameProvider>(context).getIndex),
                  height: MediaQuery.of(context).size.height-kBottomNavigationBarHeight,
                  child: _backgrounds[
                      Provider.of<SectionNameProvider>(context).getIndex],
                ),
              ),
              exCarousel,
            ],
          ),
      ),
    );
  }
}
