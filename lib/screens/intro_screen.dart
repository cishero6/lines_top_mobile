// ignore_for_file: use_build_context_synchronously



import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/blog_provider.dart';
import '../providers/exercises_provider.dart';
import '../providers/programs_provider.dart';
import '../providers/trainings_provider.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  static const routeName = '/intro';
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {

  late VideoPlayerController _videoController1;
  late VideoPlayerController _videoController2;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;


  List<Widget> _videos = [];

/*
  final List<String> _welcomeTexts = [
    'Добро пожаловать в мир Lines-Top – твоего персонального тренера и спутника на пути к лучшей версии тебя! \n\n С Lines-Top фитнес перестаёт быть скучным обязательством – это вдохновляющий опыт, привносящий радость в каждую тренировку. Наше приложение предлагает не только уникальные программы тренировок, разработанные опытными тренерами, но и создает атмосферу, в которой твоя мотивация будет на высшем уровне.',
    'Наша цель – не просто помочь тебе достичь желаемой формы, но и сделать процесс увлекательным. Интерактивные вызовы, достижения и возможность соревноваться с друзьями позволят тебе оставаться на пути к успеху. \n\n Lines-Top также следит за твоим прогрессом. Графики и статистика помогут тебе видеть свои результаты и понимать, как близко ты к своим целям. Ты будешь с удовольствием фиксировать свои достижения и делись ими с миром.',
    'Не жди – начни свой путь к здоровью и совершенству прямо сейчас с Lines-Top!',
  ];
*/

  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isWatching = true;
  bool _isError = false;




  void _fetchEverything() async {
    try{
      setState(() {
        _isError = false;
      });
    await Provider.of<BlogProvider>(context, listen: false).firstLoadItems();
    await Provider.of<ExercisesProvider>(context, listen: false).firstLoadItems();
    await Provider.of<TrainingsProvider>(context, listen: false).firstLoadItems(context);
    await Provider.of<ProgramsProvider>(context, listen: false).firstLoadItems(context);
    print('got here');
    await Provider.of<BlogProvider>(context, listen: false).fetchAndSetItems();
    await Provider.of<ExercisesProvider>(context, listen: false).fetchAndSetItems();
    await Provider.of<TrainingsProvider>(context, listen: false).fetchAndSetItems(context);
    await Provider.of<ProgramsProvider>(context, listen: false).fetchAndSetItems(context);
    await Provider.of<UserProvider>(context,listen:false).initializeData(context);
    print('initialized data');

    if(!_isWatching){
      _navigate();
      return;
    }
    setState(() {
      _isLoading = false;
    });
    } catch(e){
      print(e);
      setState(() {
        _isError = true;
      });
    }
    
    
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this,duration: const Duration(milliseconds: 1000));
    _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(_animationController);
    _videoController1 = VideoPlayerController.asset('assets/videos/intro1.mp4')..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _videoController2 = VideoPlayerController.asset('assets/videos/intro2.mp4')..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _videoController1.setLooping(false);
    _videoController2.setLooping(true);

    _videos = [
      AspectRatio(
          key: const ValueKey('first'),
          aspectRatio: 1080 / 1920,
          child: GestureDetector(
              onTap: () => setState(() {
                    _currentIndex++;
                    _videoController2.play();
                  }),
              child: VideoPlayer(_videoController1))),
      AspectRatio(
          key: const ValueKey('second'),
          aspectRatio: 1080 / 1920,
          child: GestureDetector(
              onTap: () {
                if(!_isLoading){
                  _navigate();
                }
                setState(() {
                    _isWatching = false;
                });
                _animationController.forward();
              },
              child: VideoPlayer(_videoController2))),
    ];
    _fetchEverything();
    _currentIndex = 0;
    super.initState();
  }



  @override
  void dispose() {
    _videoController1.dispose();
    _videoController2.dispose();
    super.dispose();
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





  @override
  Widget build(BuildContext context) {
    if(!_videoController1.value.isInitialized || !_videoController2.value.isInitialized){
      return const Scaffold(backgroundColor: Colors.black,);
    }
    if(_currentIndex == 0){
      _videoController1.play();
    }
    if(!_isLoading && !_isWatching){
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _videos[_currentIndex],
            ),
          ),
          if(!_isWatching) Positioned(bottom: 100,child: SizedBox(width: MediaQuery.of(context).size.width,child: FadeTransition(opacity: _opacityAnimation,child: Row(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.center,children: [Text('Загрузка',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),),const SizedBox(width: 20,),const CircularProgressIndicator(color: Colors.white,)],),))),
        if(_isError) Positioned(bottom: 150,child: SizedBox(width: MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: _fetchEverything, child: Text('Попробовать еще раз',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)))),
        ],
      ),
    );
  }
}
