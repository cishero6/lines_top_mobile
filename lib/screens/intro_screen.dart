// ignore_for_file: use_build_context_synchronously


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';
import '../providers/exercises_provider.dart';
import '../providers/programs_provider.dart';
import '../providers/trainings_provider.dart';
import '../providers/user_data_provider.dart';
import 'main_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  static const routeName = '/intro';
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _containerAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _loadingAnimationController;

  late Animation<double> _containerSizeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoPositionAnimation;
  late Animation<Offset> _loadingPositionAnimation;
  late Animation<double> _loadingFadeAnimation;

  late Animation<double> _textFadeAnimation;

  final List<String> _welcomeTexts = [
    'Добро пожаловать в мир Lines-Top – твоего персонального тренера и спутника на пути к лучшей версии тебя! \n\n С Lines-Top фитнес перестаёт быть скучным обязательством – это вдохновляющий опыт, привносящий радость в каждую тренировку. Наше приложение предлагает не только уникальные программы тренировок, разработанные опытными тренерами, но и создает атмосферу, в которой твоя мотивация будет на высшем уровне.',
    'Наша цель – не просто помочь тебе достичь желаемой формы, но и сделать процесс увлекательным. Интерактивные вызовы, достижения и возможность соревноваться с друзьями позволят тебе оставаться на пути к успеху. \n\n Lines-Top также следит за твоим прогрессом. Графики и статистика помогут тебе видеть свои результаты и понимать, как близко ты к своим целям. Ты будешь с удовольствием фиксировать свои достижения и делись ими с миром.',
    'Не жди – начни свой путь к здоровью и совершенству прямо сейчас с Lines-Top!',
  ];

  String _currentText = '';
  int _currentIndex = 0;

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _logoFadeAnimation,
      child: SlideTransition(
        position: _logoPositionAnimation,
        child: Image.asset(
          'assets/images/BlackLogo.png',
        ),
      ),
    );
  }


    bool _isLoading = true;
    bool _isWatching = true;
  

  void _fetchEverything() async {
    await Provider.of<UserDataProvider>(context,listen:false).setListener();
    await Provider.of<BlogProvider>(context, listen: false).fetchAndSetItems();
    await Provider.of<ExercisesProvider>(context, listen: false)
        .fetchAndSetItems();
    await Provider.of<TrainingsProvider>(context, listen: false)
        .fetchAndSetItems(context);
    await Provider.of<ProgramsProvider>(context, listen: false)
        .fetchAndSetItems(context);
    if(!_isWatching){
      await _textAnimationController.reverse();
      await _loadingAnimationController.reverse();
      _navigate();
      return;
    }
    setState(() {
      _isLoading = false;
    });
    
  }

  @override
  void initState() {
    _fetchEverything();
    _currentIndex = 0;
    _currentText = _welcomeTexts[_currentIndex];
    _logoAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _containerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _textAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _loadingAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoAnimationController, curve: Curves.ease));
    _logoPositionAnimation =
        Tween(begin: const Offset(0.0, -0.5), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _logoAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));
    _containerSizeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _containerAnimationController, curve: Curves.ease));

    _textFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textAnimationController, curve: Curves.ease));

    _loadingFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _loadingAnimationController, curve: Curves.ease));
     _loadingPositionAnimation =
        Tween(begin: const Offset(0.0, 0.5), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _loadingAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));

    _begin();
    super.initState();
  }

  void _begin()async{
    await Future.delayed(const Duration(milliseconds: 300));
    await _containerAnimationController.forward();
    _logoAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await _textAnimationController.forward();
    _textAnimationController.duration = const Duration(milliseconds: 400);

  }

  void _navigate() async{
    Navigator.pushReplacement(
      context,
      PageTransition(
        child: const MainScreen(
          didFetch: true,
        ),
        type: PageTransitionType.fade,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(seconds: 1),
      ),
    );
  }


  void _pressNext()async{
    if (_currentIndex == _welcomeTexts.length - 1) {
      if (!_isLoading) {
        _navigate();
        return;
      }
      await _textAnimationController.reverse();
      setState(() {
        _isWatching = false;
      });
      return;
    }
    _currentIndex++;
    await _textAnimationController.reverse();
    setState(() {_currentText = _welcomeTexts[_currentIndex];});
    _textAnimationController.forward();
  }

  void _startLoadingAnimations()async{
   await Future.delayed(const Duration(milliseconds: 500));
   await _loadingAnimationController.forward();
   _textAnimationController.forward();
  }

  Widget _buildTextPart() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                _currentText,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
            ),
            TextButton(
                onPressed: _pressNext,
                child: Text(
                  'Далее',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SlideTransition(
          position: _loadingPositionAnimation,
          child: FadeTransition(
            opacity: _loadingFadeAnimation,
            child: const Padding(
              padding: EdgeInsets.all(40.0),
              child: CupertinoActivityIndicator(
                  radius: 30, color: CupertinoColors.white),
            ),
          ),
        ),
        FadeTransition(
          opacity: _textFadeAnimation,
          child: Text(
            'Секунду...',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ScaleTransition(
            scale: _containerSizeAnimation,
            child: OverflowBox(
              maxHeight: MediaQuery.of(context).size.longestSide*3,
              maxWidth: MediaQuery.of(context).size.longestSide*3,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 90, 90, 90),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SafeArea(child: SizedBox()),
                Flexible(
                  flex: 2,
                  child: _buildLogo(),),
                Flexible(
                  flex: 4,
                  child: _isWatching? _buildTextPart():Builder(builder: (_){
                    _startLoadingAnimations();
                     return _buildLoadingPart();
                  }),
                ),
                const SizedBox(height: 50,),
              ],
            ),
          ),],
      ),
    );
  }
}
