import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/screens/program_process_screens/exercise_process_screen.dart';
import 'package:provider/provider.dart';

import '../../models/training.dart';
import '../../providers/exercises_provider.dart';

class LoadSetScreen extends StatefulWidget {
  final Training training;  
  final String initialSection;
  const LoadSetScreen(this.training, this.initialSection,{super.key});

  static const routeName = 'blog/load_set';
  @override
  State<LoadSetScreen> createState() => _LoadSetScreenState();
}

class _LoadSetScreenState extends State<LoadSetScreen> with TickerProviderStateMixin{
  late AnimationController _firstController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  late AnimationController _waitTextController;
  late AnimationController _progressController;
  late Animation<double> _progressScaleAnimation;
  late Animation<Offset> _waitTextSlideAnimation;
  late Animation<double> _waitTextFadeAnimation;
  bool _doneLoading = false;


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
        _loadSet();
    super.initState();
  }


  void _loadSet()async{
    _animateTitle();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _waitTextController.forward();
    }
    if (mounted) {
      _progressController.forward();
    }
   await Future.delayed(const Duration(milliseconds: 800));
    List<String> fetchedIds = [];
    var collection = (await FirebaseFirestore.instance.collection('exercises').get()).docs;
    for (var section in widget.training.sections.entries) {
      for (var exercise in section.value) {
        if (exercise.video == null) {
          if (!fetchedIds.contains(exercise.id)) {
            if (exercise.version != collection.singleWhere((element) => element.id == exercise.id).data()['version']){
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
    
    if(mounted){
      await _waitTextController.reverse();
      _doneLoading = true;
      setState(() {});
      await _progressController.reverse();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(ExerciseProcessScreen.routeName,arguments: [widget.training,widget.initialSection,null,null]);
    }

  }

    void _animateTitle() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _firstController.forward();
    }
  }

  @override
  void dispose() {
    _firstController.dispose();
    _progressController.dispose();
    _waitTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/bg_24.jpg'),
                opacity: 0.9,
                fit: BoxFit.cover)),
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              pinned: false,
              title: SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    'Пару секунд',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            SliverToBoxAdapter(
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
                                'Загружаем сет...',
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}