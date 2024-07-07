// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/screens/details_screens/blog_post_details_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/add_parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/programs_progress_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/register_parameters_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/load_set_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/trainings_list_screen.dart';
import 'package:video_player/video_player.dart';
import '../helpers/phone_auth_status.dart';
import '../providers/exercises_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/my_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import './navigation_bar_screens/blog_screen.dart';
import './navigation_bar_screens/profile_screen.dart';
import './navigation_bar_screens/programs_screen.dart';
import './navigation_bar_screens/info_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../providers/blog_provider.dart';
import '../providers/programs_provider.dart';
import '../providers/trainings_provider.dart';
import 'control_panel_screens/add_screens/add_blog_post_screen.dart';
import 'control_panel_screens/add_screens/add_exercise_screen.dart';
import 'control_panel_screens/add_screens/add_program_screen.dart';
import 'control_panel_screens/add_screens/add_training_screen.dart';
import 'control_panel_screens/control_panel_screen.dart';
import 'control_panel_screens/edit_screens/edit_blog_post_screen.dart';
import 'control_panel_screens/edit_screens/edit_exercise_screen.dart';
import 'control_panel_screens/edit_screens/edit_program_screen.dart';
import 'control_panel_screens/edit_screens/edit_training_screen.dart';
import 'details_screens/program_details_screen.dart';
import 'more_screens.dart/all_posts_screen.dart';
import 'navigation_bar_screens/all_sets_screen.dart';
import 'profile_screens/control_screen.dart';
import 'program_process_screens/exercise_process_screen.dart';
import 'program_process_screens/sections_list_screen.dart';

class MainScreen extends StatefulWidget {
  final bool didFetch;
  const MainScreen({required this.didFetch,super.key});
  static const routeName = '/';
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late VideoPlayerController _videoController;

  bool _isLoading = true;
  bool _isError = false;
  String _loadingText = '';
  

  void _fetchEverything() async {
    try{
      setState(() {
        _isError = false;
      });
    setState(() {
      _loadingText = 'Загружаем блог';
    });
    await Provider.of<BlogProvider>(context, listen: false).fetchAndSetItems();
    setState(() {
      _loadingText = 'Загружаем упражнения';
    });
    await Provider.of<ExercisesProvider>(context, listen: false)
        .fetchAndSetItems();
    setState(() {
      _loadingText = 'Загружаем тренировки';
    });
    await Provider.of<TrainingsProvider>(context, listen: false)
        .fetchAndSetItems(context);
    setState(() {
      _loadingText = 'Загружаем программы';
    });
    await Provider.of<ProgramsProvider>(context, listen: false)
        .fetchAndSetItems(context);
    await Provider.of<UserProvider>(context,listen:false).initializeData(context);
          //print(Provider.of<UserProvider>(context,listen:false).username);
    isReg = Provider.of<UserProvider>(context,listen:false).username == null;
    setState(() {
      _isLoading = false;
    });
    _videoController.dispose();
    } catch (e) {
      setState(() {
        _isError = true;
      });
      print(e.toString());
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    
  }

  @override
  void initState() {
    if(!widget.didFetch){
      _fetchEverything();
      _videoController = VideoPlayerController.asset('assets/videos/intro1.mp4')..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
      _videoController.setLooping(true);
    } else{
      _isLoading = false;
    }
    super.initState();
  }



  Widget _buildOldStage(){
return Container(
            color: Colors.white,
            child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/BlackLogo.png'),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(
                    color: Colors.black,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    _loadingText,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
          );
  }
  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    print('main screen build');
    if(!widget.didFetch && _isLoading){
      if(!_videoController.value.isInitialized){
        return const Scaffold(backgroundColor: Colors.black,);
      }else{
        _videoController.play();
      }
    }
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(title: const Text('Саша ЧМООО'),elevation: 1,),
      body: _isLoading
          ? Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 1080 / 1920,
                    child: VideoPlayer(_videoController),
                  ),
                ),
        Positioned(bottom: 100,child: SizedBox(width: MediaQuery.of(context).size.width,child: Row(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.center,children: [Text(_loadingText,style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),),const SizedBox(width: 20,),const CircularProgressIndicator(color: Colors.white,)],))),
        if(_isError) Positioned(bottom: 150,child: SizedBox(width: MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: _fetchEverything, child: Text('Попробовать еще раз',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)))),
        if(_isError) Positioned(bottom: 350,child: SizedBox(width: MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: DBHelper.deleteTables, child: Text('удалить табицы',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)))),

      ],
    )
          : Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) {
                 switch (settings.name) {
            case ProfileScreen.routeName:
              return PageTransition(child: const ProfileScreen(), type: PageTransitionType.fade);
            case ProgramsScreen.routeName:
              return PageTransition(child: const ProgramsScreen(), type: PageTransitionType.fade);
            case BlogScreen.routeName:
              return PageTransition(child: const BlogScreen(), type: PageTransitionType.fade);
            case InfoScreen.routeName:
              return PageTransition(child: const InfoScreen(), type: PageTransitionType.fade);
            case ParametersScreen.routeName:
                //final List<dynamic> args = settings.arguments as List<dynamic>;
              //   if(false){
              // return PageTransition(child: const ParametersScreen(), type: PageTransitionType.bottomToTopJoined,childCurrent: args[1],curve: Curves.fastLinearToSlowEaseIn,duration: const Duration(seconds: 2));
              //   }
                return PageTransition(child: const ParametersScreen(), type: PageTransitionType.fade);
            // case DeleteAccountVerificationScreen.routeName:
            //     return MaterialPageRoute(builder: (ctx)=> const DeleteAccountVerificationScreen());
            case ExerciseProcessScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return PageTransition(child: ExerciseProcessScreen(args[0],args[1],programId: args[2],trainingIndex: args[3],), type: PageTransitionType.rightToLeft);
            case ControlScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const ControlScreen());
            case RegisterParametersScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              if(args[0]){
              return PageTransition(child: const RegisterParametersScreen(), type: PageTransitionType.size,alignment: Alignment.center,curve: Curves.fastEaseInToSlowEaseOut,duration: const Duration(seconds: 1),reverseDuration: const Duration(seconds: 1));
                }
                return MaterialPageRoute(builder: (ctx)=> const RegisterParametersScreen());
            case ProgramDetailsScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> ProgramDetailsScreen(args[0]));
            case TrainingsListScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> TrainingsListScreen(args[0]));
            case LoadSetScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> LoadSetScreen(args[0],args[1]));
            case SectionsListScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> SectionsListScreen(args[0],programId: args[1],trainingIndex: args[2],));
            case ControlPanelScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> ControlPanelScreen(args[0]));
            case EditExerciseScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> EditExerciseScreen(args[0]));
            case EditTrainingScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> EditTrainingScreen(args[0]));
            case EditProgramScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> EditProgramScreen(args[0]));
            case EditBlogPostScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> EditBlogPostScreen(args[0]));
            case AddBlogPostScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AddBlogPostScreen());
             case AddExerciseScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AddExerciseScreen());
            case AddTrainingScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AddTrainingScreen());
            case AddProgramScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AddProgramScreen());
            case AllSetsScreen.routeName:
              return PageTransition(child: const AllSetsScreen(), type: PageTransitionType.fade);
            case AllPostsScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AllPostsScreen());
            case AddParametersScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const AddParametersScreen());
            case ProgramsProgressScreen.routeName:
              return MaterialPageRoute(builder: (ctx)=> const ProgramsProgressScreen());
            // case ChangeDataScreen.routeName:
            //   return MaterialPageRoute(builder: (ctx)=> const ChangeDataScreen());
            case BlogPostDetailsScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> BlogPostDetailsScreen(args[0]));
            default:
              return MaterialPageRoute(builder: (ctx)=> const BlogScreen());
          }
              },
            ),
      bottomNavigationBar: _isLoading ? null : MyBottomNavigationBar(navigatorKey: _navigatorKey,),
    );
  }
}
