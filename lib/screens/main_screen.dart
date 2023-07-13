import 'package:flutter/material.dart';
import 'package:lines_top_mobile/screens/details_screens/blog_post_details_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/trainings_list_screen.dart';
import '../providers/exercises_provider.dart';
import '../widgets/my_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import './navigation_bar_screens/blog_screen.dart';
import './navigation_bar_screens/profile_screen.dart';
import './navigation_bar_screens/programs_screen.dart';
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
import 'navigation_bar_screens/profile_screens/auth_screen.dart';
import 'navigation_bar_screens/profile_screens/control_screen.dart';
import 'program_description_screen.dart';
import 'program_process_screens/exercise_process_screen.dart';
import 'program_process_screens/sections_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const routeName = '/';
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  bool _isLoading = true;
  String _loadingText = '';


  void _fetchEverything() async {
    setState(() {
      _loadingText = 'Загружаем блог';
    });
    await Provider.of<BlogProvider>(context, listen: false).fetchAndSetItems();
    setState(() {
      _loadingText = 'Загружаем упражнения';
    });
    // ignore: use_build_context_synchronously
    await Provider.of<ExercisesProvider>(context, listen: false)
        .fetchAndSetItems();
    setState(() {
      _loadingText = 'Загружаем тренировки';
    });
    // ignore: use_build_context_synchronously
    await Provider.of<TrainingsProvider>(context, listen: false)
        .fetchAndSetItems(context);
    setState(() {
      _loadingText = 'Загружаем программы';
    });
    // ignore: use_build_context_synchronously
    await Provider.of<ProgramsProvider>(context, listen: false)
        .fetchAndSetItems(context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchEverything();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Саша ЧМООО'),elevation: 1,),
      body: _isLoading
          ? Center(
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
            ))
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
            case ControlScreen.routeName:
              return PageTransition(child: const ControlScreen(), type: PageTransitionType.fade);
            case AuthScreen.routeName:
              return PageTransition(child: const AuthScreen(), type: PageTransitionType.fade);
            case ProgramDescriptionScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> ProgramDescriptionScreen(args[0]));
            case TrainingsListScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> TrainingsListScreen(args[0]));
            case SectionsListScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> SectionsListScreen(args[0],programId: args[1],trainingIndex: args[2],));
            case ExerciseProcessScreen.routeName:
              final List<dynamic> args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (ctx)=> ExerciseProcessScreen(args[0],args[1],programId: args[2],trainingIndex: args[3],));
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
