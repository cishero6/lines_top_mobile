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

class _TrainingsListScreenState extends State<TrainingsListScreen>
    with TickerProviderStateMixin {
  late AnimationController _firstController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  bool _disposed = false;

  @override
  void initState() {
    _firstController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _titleFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _firstController, curve: Curves.fastLinearToSlowEaseIn));
    _titleSlideAnimation =
        Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _firstController,
                curve: Curves.fastLinearToSlowEaseIn));
    super.initState();
  }

  void _animate() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_disposed) {
      _firstController.forward();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_firstController.isAnimating) {
      _firstController.stop();
    }
    _firstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animate();
    var progressData = Provider.of<UserDataProvider>(context).progress;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    widget.program.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          SliverList.builder(
            itemCount: widget.program.trainings.length,
            itemBuilder: (ctx, index) => HorizontalListItem(
              title: 'Тренировка ${index + 1}',
              onPressed: () {
                Navigator.of(context).pushNamed(SectionsListScreen.routeName,
                    arguments: [
                      widget.program.trainings[index],
                      widget.program.id,
                      index
                    ]);
              },
              goldenColor: progressData![widget.program.id]![index] == 100,
              middleItem: Text('${progressData[widget.program.id]![index]}%'),
              //middleItem: SizedBox(width: 80,child: LinearProgressIndicator(backgroundColor: Colors.black,color: Colors.red,value: progressData![widget.program.id]![index].toDouble()/100,)),
              waitTimer: Duration(milliseconds: 200 + index * 300),
            ),
          ),
        ],
      ),
    );
  }
}
