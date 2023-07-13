import 'package:flutter/material.dart';
import '../../models/program.dart';
import '../../widgets/list_items/horizontal_list_item.dart';
import 'sections_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';

class TrainingsListScreen extends StatefulWidget {
  final Program program;
  const TrainingsListScreen(this.program, {super.key});
  static const routeName = '/trainings_list';
  @override
  State<TrainingsListScreen> createState() => _TrainingsListScreenState();
}

class _TrainingsListScreenState extends State<TrainingsListScreen> {

  @override
  Widget build(BuildContext context) {
    var progressData = Provider.of<UserDataProvider>(context).progress;
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              widget.program.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SliverToBoxAdapter(
            child: UnconstrainedBox(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(Size(deviceSize.width * 0.8, 500)),
                child: ListView.builder(
                  itemCount: widget.program.trainings.length,
                  itemBuilder: (context, index) => HorizontalListItem(
                    title: 'Тренировка ${index + 1}',
                    onPressed: () {
                      Navigator.of(context).pushNamed(SectionsListScreen.routeName,arguments: [widget.program.trainings[index],widget.program.id,index]);
                    },
                    goldenColor: progressData![widget.program.id]![index]==100,
                    middleItem: Text('${progressData[widget.program.id]![index]}%'),
                    //middleItem: SizedBox(width: 80,child: LinearProgressIndicator(backgroundColor: Colors.black,color: Colors.red,value: progressData![widget.program.id]![index].toDouble()/100,)),
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
