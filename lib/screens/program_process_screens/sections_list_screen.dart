import 'package:flutter/material.dart';
import 'package:lines_top_mobile/screens/program_process_screens/exercise_process_screen.dart';
import '../../models/training.dart';
import '../../widgets/list_items/horizontal_list_item.dart';


class SectionsListScreen extends StatefulWidget {
  final Training training;
  final String programId;
  final int trainingIndex;
  static const routeName = '/sections_list';
  const SectionsListScreen(this.training,{required this.programId,required this.trainingIndex,super.key});

  @override
  State<SectionsListScreen> createState() => _SectionsListScreenState();
}

class _SectionsListScreenState extends State<SectionsListScreen> with TickerProviderStateMixin{

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
    if (!_disposed) {_firstController.forward();}
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
    List<String> orderedKeys = widget.training.sections.keys.toList()..sort((a,b)=> a.split('_').last.compareTo(b.split('_').last));
    return Scaffold(
      body: Container(
        decoration:const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_27.jpg'),opacity: 0.85,fit: BoxFit.cover)
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
      backgroundColor: Colors.transparent,
              title: SlideTransition(
                  position: _titleSlideAnimation,
                  child: FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: Text(
                      'Выбор секции',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  ),),
            ),
            SliverList.builder(itemCount: widget.training.sections.length,itemBuilder: (ctx,index)=>HorizontalListItem(
                      title: orderedKeys[index].split('_').first,
                      onPressed: () {
                        Navigator.of(context).pushNamed(ExerciseProcessScreen.routeName,arguments: [widget.training,orderedKeys[index],widget.programId,widget.trainingIndex]);
                      },
                      waitTimer: Duration(milliseconds: 200 + index * 300),
                    ),),
          ],
        ),
      ),
    );
  }
}