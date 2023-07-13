import 'package:flutter/material.dart';
import 'package:lines_top_mobile/screens/program_process_screens/exercise_process_screen.dart';
import '../../models/training.dart';
import '../../widgets/list_items/horizontal_list_item.dart';


class SectionsListScreen extends StatelessWidget {
  final Training training;
  final String programId;
  final int trainingIndex;
  static const routeName = '/sections_list';
  const SectionsListScreen(this.training,{required this.programId,required this.trainingIndex,super.key});

  @override
  Widget build(BuildContext context) {
    List<String> orderedKeys = training.sections.keys.toList()..sort((a,b)=> a.split('_').last.compareTo(b.split('_').last));
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              training.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SliverToBoxAdapter(
            child: UnconstrainedBox(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(Size(deviceSize.width * 0.8, 500)),
                child: ListView.builder(
                  itemCount: training.sections.length,
                  itemBuilder: (context, index) => HorizontalListItem(
                    title: orderedKeys[index].split('_').first,
                    onPressed: () {
                      Navigator.of(context).pushNamed(ExerciseProcessScreen.routeName,arguments: [training,orderedKeys[index],programId,trainingIndex]);
                    },
                    waitTimer: Duration(milliseconds: 200 + index * 300),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}