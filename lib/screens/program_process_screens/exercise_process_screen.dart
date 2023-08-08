import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/section_name_provider.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/widgets/list_items/exercise_carousel_item.dart';
import 'package:provider/provider.dart';
import '../../models/training.dart';
import '../../models/exercise.dart';

import '../../widgets/exercises_carousel.dart';

class ExerciseProcessScreen extends StatefulWidget {
  final String initialSection;
  final String programId;
  final int trainingIndex;
  final Training training;
  const ExerciseProcessScreen(this.training, this.initialSection, {required this.programId,required this.trainingIndex,super.key});
  static const routeName = '/trainings_list/sections_list/exercise_process';
  @override
  State<ExerciseProcessScreen> createState() => _ExerciseProcessScreenState();
}

class _ExerciseProcessScreenState extends State<ExerciseProcessScreen> {
  late ExercisesCarousel exCarousel;
  late AppBar appBar;
  List<Map<String, Exercise>> _orderedExercises = [];


  

  Future<bool> _onWillPop() async {
    Map<String,List<int>> curProgress = {...Provider.of<UserDataProvider>(context,listen: false).progress!};
    curProgress[widget.programId]![widget.trainingIndex] = (exCarousel.currentIndex / _orderedExercises.length * 100).round();
    await Provider.of<UserDataProvider>(context,listen: false).updateProgress(curProgress, context: context);
    return true;
  }

  @override
  void initState() {
    Provider.of<SectionNameProvider>(context, listen: false)
        .initiateSectionName(widget.initialSection);
    var orderedKeys = widget.training.sections.keys.toList()
      ..sort((a, b) => a.split('_').last.compareTo(b.split('_').last));
    for (int i = 0; i < orderedKeys.length; i++) {
      _orderedExercises.addAll(widget.training.sections[orderedKeys[i]]!
          .map((e) => {orderedKeys[i]: e}));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
        appBar = AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                Provider.of<SectionNameProvider>(context)
                    .sectionName
                    .split('_')
                    .first,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
    int initialIndex;
    int keyIndex = 0;
    initialIndex = _orderedExercises.indexWhere((element) => element.keys.first == widget.initialSection);
    exCarousel = ExercisesCarousel(
      height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight-appBar.preferredSize.height,
      initialIndex: initialIndex,
                onEndTraining: () {
                  _onWillPop();Navigator.of(context).pop();Navigator.of(context).pop();
                },
                items: _orderedExercises
                    .map((e) => ExerciseCarouselItem(e.values.first,key: ValueKey(keyIndex++),))
                    .toList(),
                sectionNames: _orderedExercises.map((e) => e.keys.first).toList(),
              );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: exCarousel
      ),
    );
  }
}
