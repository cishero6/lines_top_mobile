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
  final double? skipHeight;
  int currentIndex = 0;
  final void Function() onEndTraining;
  ExercisesCarousel(
      {super.key,
      required this.items,
      this.initialIndex = 0,
      required this.onEndTraining,
      required this.sectionNames,
      this.skipHeight});

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

  bool _secondIsPrimary = false;
  int _currentIndex = 0;

  late AnimationController _animtaionController;
  late Animation<Offset> _primaryOffsetAnimation;
  late Animation<Offset> _secondOffsetAnimation;

  void _finishTraining(){
    if(_secondIsPrimary){
      _secondWidget = const SizedBox(width: 1,height: 1,);
    } else{
      _primaryWidget = const SizedBox(width: 1,height: 1,);
    }
    setState(() {});
    widget.onEndTraining();
  }


  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _primaryWidget = widget.items[_currentIndex];
    _animtaionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
    _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(-10, 0));
    super.initState();
  }

  void _nextPage() async {
    if(_animtaionController.isAnimating){
      return;
    }
    _animtaionController.reset();
    if (_currentIndex + 1 == widget.items.length) {
      final finalWidget = Column(
        //ПЕРЕДЕЛАТЬ (КОНЕЦ ТРЕНИРОВКИ!)
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Тренировка выполнена!',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: _finishTraining,
              child: Text(
                'Завершить тренировку',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
              ))
        ],
      );
      _secondIsPrimary ? _primaryWidget = finalWidget : _secondWidget = finalWidget;
    } else {
      if (!_secondIsPrimary) {
        _secondWidget = widget.items[_currentIndex + 1];
      } else {
        _primaryWidget = widget.items[_currentIndex + 1];
      }
      if (Provider.of<SectionNameProvider>(context, listen: false)
              .sectionName !=
          widget.sectionNames[_currentIndex + 1]) {
        Provider.of<SectionNameProvider>(context, listen: false)
            .setSectionName(widget.sectionNames[_currentIndex + 1]);
      }
    }
    _currentIndex++;
    setState(() {});

    if (!_secondIsPrimary) {
      _primaryOffsetAnimation =
          Tween(begin: const Offset(0, 0), end: const Offset(-1.4, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      _secondOffsetAnimation =
          Tween(begin: const Offset(1.4, 0), end: const Offset(0, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      await _animtaionController.forward();
      _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(10, 0));
      _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));

    } else {
      _primaryOffsetAnimation =
          Tween(begin: const Offset(1.4, 0.0), end: const Offset(0.0, 0.0))
              .animate(CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      _secondOffsetAnimation =
          Tween(begin: const Offset(0, 0), end: const Offset(-1.4, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      if (!mounted) {
        return;
      }
      await _animtaionController.forward();
      _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
      _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(10, 0));

    }

    _secondIsPrimary = !_secondIsPrimary;

      setState(() {});
  }

  void _previousPage() async {
        if(_animtaionController.isAnimating){
      return;
    }
    _animtaionController.reset();
    if (!_secondIsPrimary) {
      _secondWidget = widget.items[_currentIndex - 1];
    } else {
      _primaryWidget = widget.items[_currentIndex - 1];
    }
    if (Provider.of<SectionNameProvider>(context, listen: false).sectionName !=
        widget.sectionNames[_currentIndex - 1]) {
      Provider.of<SectionNameProvider>(context, listen: false)
          .setSectionName(widget.sectionNames[_currentIndex - 1]);
    }
    _currentIndex--;
    setState(() {});
    if (!_secondIsPrimary) {
      _primaryOffsetAnimation =
          Tween(begin: const Offset(0, 0), end: const Offset(1.4, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      _secondOffsetAnimation =
          Tween(begin: const Offset(-1.4, 0), end: const Offset(0, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      await _animtaionController.forward();


      _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
      _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(10, 0));

    } else {
      _primaryOffsetAnimation =
          Tween(begin: const Offset(-1.4, 0), end: const Offset(0, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      _secondOffsetAnimation =
          Tween(begin: const Offset(0, 0), end: const Offset(1.4, 0)).animate(
              CurvedAnimation(
                  parent: _animtaionController, curve: Curves.ease));
      await _animtaionController.forward();

      _primaryOffsetAnimation = const AlwaysStoppedAnimation(Offset(110, 0));
      _secondOffsetAnimation = const AlwaysStoppedAnimation(Offset(0, 0));
    }

    _secondIsPrimary = !_secondIsPrimary;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
        _animtaionController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    widget.currentIndex = _currentIndex;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 8,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.white54,Colors.transparent],begin: Alignment.bottomCenter,end: Alignment.topCenter,stops: [0.0,0.2])),
                child: Stack(
                  children: [
                    SlideTransition(
                        position: _primaryOffsetAnimation,
                        child: Align(
                          alignment: Alignment.center,
                          child: _primaryWidget,
                        )),
                    SlideTransition(
                      position: _secondOffsetAnimation,
                      child: Align(
                        alignment: Alignment.center,
                        child: _secondWidget,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.white,Colors.white54],stops: [0.0,1],begin: Alignment.bottomCenter,end: Alignment.topCenter)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: _currentIndex == 0 ? null : _previousPage,
                        icon: const Icon(
                          Icons.arrow_back_ios
                        )),
                    IconButton(
                      onPressed:
                          _currentIndex == widget.items.length ? null : _nextPage,
                      icon: const Icon(
                        Icons.arrow_forward_ios
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        /*
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Swiping in right direction.
              if (details.delta.dx > 0) {
                if (_currentIndex != 0) _previousPage();
              }

              // Swiping in left direction.
              if (details.delta.dx < 0) {
                if (_currentIndex != widget.items.length) _nextPage();
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
        ),
        */
      ]),
    );
  }
}
