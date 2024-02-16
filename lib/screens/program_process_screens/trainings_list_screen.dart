import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/exercises_provider.dart';
import '../../models/program.dart';
import '../../providers/user_provider.dart';
import '../../widgets/list_items/horizontal_list_item.dart';
import 'sections_list_screen.dart';
import 'package:provider/provider.dart';

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

  late AnimationController _waitTextController;
  late AnimationController _progressController;
  late Animation<double> _progressScaleAnimation;
  late Animation<Offset> _waitTextSlideAnimation;
  late Animation<double> _waitTextFadeAnimation;
  bool _isLoadingProgram = true;
  bool _doneLoading = false;
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

    _progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _waitTextController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _progressScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.fastLinearToSlowEaseIn));
    _waitTextFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _waitTextController, curve: Curves.fastLinearToSlowEaseIn));
    _waitTextSlideAnimation =
        Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _waitTextController,
                curve: Curves.fastLinearToSlowEaseIn));
        _loadProgram();
    super.initState();
  }

  void _loadProgram() async {
    _animate();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_disposed) {
      _waitTextController.forward();
    }
    if (!_disposed) {
      _progressController.forward();
    }
    List<String> fetchedIds = [];
    var collection = (await FirebaseFirestore.instance.collection('exercises').get()).docs;
    for (var training in widget.program.trainings) {
      for (var section in training.sections.entries) {
        for (var exercise in section.value) {
          if (exercise.video == null) {
            if (exercise.version != collection.singleWhere((element) => element.id == exercise.id).data()['version']){
              if (!fetchedIds.contains(exercise.id)) {
                if (mounted) {
                  await Provider.of<ExercisesProvider>(context, listen: false)
                      .fetchVideo(exercise);
                  fetchedIds.add(exercise.id);
                }
              }
            }
          }
        }
      }
    }
    if(!_disposed){
      await _waitTextController.reverse();
      _doneLoading = true;
      setState(() {});
      await _progressController.reverse();
      setState(() {
        _isLoadingProgram = false;
      });
    }

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
    if (_waitTextController.isAnimating) {
      _waitTextController.stop();
    }
    _waitTextController.dispose();
    if (_progressController.isAnimating) {
      _progressController.stop();
    }
    _progressController.dispose();
    super.dispose();
  }


  

  @override
  Widget build(BuildContext context) {

    var progressData = Provider.of<UserProvider>(context).progress;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/bg_24.jpg'),
                fit: BoxFit.cover,
                opacity: 0.9),
            ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: false,
              title: SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    widget.program.title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            _isLoadingProgram
                ? SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          ScaleTransition(
                            scale: _progressScaleAnimation,
                            child: AnimatedSwitcher(
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: RotationTransition(
                                          turns: Tween(begin: 1.0,end: 0.0).animate(animation),
                                          child: child,
                                        ),
                                      ),
                                    ),
                                duration: const Duration(milliseconds: 300),
                                child: _doneLoading
                                    ? const Icon(
                                        Icons.done_rounded,
                                        size: 70,
                                        color: Colors.green,
                                      )
                                    : const CupertinoActivityIndicator(
                                        radius: 30,
                                        color: CupertinoColors.systemPink)),
                          ),
                          const SizedBox(height: 50,),
                          SlideTransition(
                            position: _waitTextSlideAnimation,
                            child: FadeTransition(
                              opacity: _waitTextFadeAnimation,
                              child: Text(
                                'Загружаем программу...',
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: widget.program.trainings.length,
                    itemBuilder: (ctx, index) => HorizontalListItem(
                      title: 'Тренировка ${index + 1}',
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(SectionsListScreen.routeName, arguments: [
                          widget.program.trainings[index],
                          widget.program.id,
                          index
                        ]);
                      },
                      goldenColor:
                          progressData![widget.program.id]![index] == 100,
                      middleItem:
                          Text('${progressData[widget.program.id]![index]}%',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color.fromARGB(173, 255, 255, 255)),),
                      //middleItem: SizedBox(width: 80,child: LinearProgressIndicator(backgroundColor: Colors.black,color: Colors.red,value: progressData![widget.program.id]![index].toDouble()/100,)),
                      waitTimer: Duration(milliseconds: 200 + index * 300),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
