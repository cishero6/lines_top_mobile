// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lines_top_mobile/providers/section_name_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ExercisesCarousel extends StatefulWidget {
  final List<Widget> items;
  final List<String> sectionNames;
  final int initialIndex;
  final void Function() onEndTraining;
  int currentIndex = 0;
  ExercisesCarousel({super.key, required this.items, this.initialIndex = 0,required this.onEndTraining,required this.sectionNames});

  @override
  State<ExercisesCarousel> createState() => _ExercisesCarouselState();
}

class _ExercisesCarouselState extends State<ExercisesCarousel>
    with TickerProviderStateMixin {
  Widget _secondWidget = const SizedBox(
    height: 1,
    width: 1,
  );
  Widget _primaryWidget = const SizedBox();

  late AnimationController _animtaionController;
  late Animation<Offset> _primaryOffsetAnimation;
  late Animation<Offset> _secondOffsetAnimation;

  @override
  void initState() {
    widget.currentIndex = widget.initialIndex;
    _primaryWidget = widget.items[widget.currentIndex];
    _animtaionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
    _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(-10, 0));
    super.initState();
  }

  void _nextPage() async {
    if(widget.currentIndex + 1 == widget.items.length){
      _secondWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        Text('Тренировка выполнена!',style: Theme.of(context).textTheme.headlineMedium,textAlign: TextAlign.center,),
        ElevatedButton(onPressed: widget.onEndTraining, child: Text('Завершить тренировку',style: Theme.of(context).textTheme.bodyMedium,))
      ],);
    }else{
    _secondWidget = widget.items[widget.currentIndex + 1];
    if(Provider.of<SectionNameProvider>(context,listen:false).sectionName != widget.sectionNames[widget.currentIndex+1]){
      Provider.of<SectionNameProvider>(context,listen:false).setSectionName(widget.sectionNames[widget.currentIndex+1]);
    }
    }
    setState(() {});
    _primaryOffsetAnimation =
        Tween(begin: const Offset(0, 0), end: const Offset(-1.4, 0)).animate(
            CurvedAnimation(
                parent: _animtaionController,
                curve: Curves.ease));
    _secondOffsetAnimation =
        Tween(begin: const Offset(1.4, 0), end: const Offset(0, 0)).animate(
            CurvedAnimation(
                parent: _animtaionController,
                curve: Curves.ease));
    await _animtaionController.forward();
    _primaryWidget = _secondWidget;
    _secondWidget = const SizedBox();
    _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
    _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(-10, 0));
    widget.currentIndex++;
    setState(() {});
    
    _animtaionController.reset();
  }

  void _previousPage() async {
    _secondWidget = widget.items[widget.currentIndex - 1];
    if(Provider.of<SectionNameProvider>(context,listen:false).sectionName != widget.sectionNames[widget.currentIndex-1]){
      Provider.of<SectionNameProvider>(context,listen:false).setSectionName(widget.sectionNames[widget.currentIndex-1]);
    }
    setState(() {});

    _primaryOffsetAnimation =
        Tween(begin: const Offset(0, 0), end: const Offset(1.4, 0)).animate(
            CurvedAnimation(
                parent: _animtaionController,
                curve: Curves.ease));
    _secondOffsetAnimation =
        Tween(begin: const Offset(-1.4, 0), end: const Offset(0, 0)).animate(
            CurvedAnimation(
                parent: _animtaionController,
                curve: Curves.ease));
    await _animtaionController.forward();
    _primaryWidget = _secondWidget;
    _secondWidget = const SizedBox();
    _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
    _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(-10, 0));
    widget.currentIndex--;

    setState(() {});
    _animtaionController.reset();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(children: [
        Column(
          children: [
            Flexible(
                fit: FlexFit.tight,
                flex: 6,
                child: Stack(
                  children: [
                    SlideTransition(
                        position: _secondOffsetAnimation,
                        child: Align(
                          alignment: Alignment.center,
                          child: _secondWidget,
                        )),
                    SlideTransition(
                        position: _primaryOffsetAnimation,
                        child: Align(
                          alignment: Alignment.center,
                          child: _primaryWidget,
                        )),
                  ],
                )),
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: widget.currentIndex == 0 ? null :_previousPage,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                      )),
                  IconButton(
                    onPressed: widget.currentIndex == widget.items.length ? null : _nextPage,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              print('ddsw');
              // Swiping in right direction.
              if (details.delta.dx > 0) {
                if(widget.currentIndex!=0) _previousPage();
              }

              // Swiping in left direction.
              if (details.delta.dx < 0) {
                if(widget.currentIndex!= widget.items.length) _nextPage();
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
        ),
      ]),
    );
  }
}
