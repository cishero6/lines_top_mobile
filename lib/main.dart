import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/providers/verification_id_provider.dart';
import 'package:lines_top_mobile/screens/intro_screen.dart';
import './providers/blog_provider.dart';
import './providers/trainings_provider.dart';
import './screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import './providers/programs_provider.dart';
import 'providers/bottom_navigation_provider.dart';
import 'providers/exercises_provider.dart';
import './helpers/color_schemes.g.dart';

import 'providers/section_name_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isFirst = !(await DBHelper.exists());

  runApp(MyApp(isFirstBuild: isFirst,));
}

class MyApp extends StatelessWidget {
  
  final bool isFirstBuild;
  const MyApp({required this.isFirstBuild ,super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SectionNameProvider>(
          create: (_) => SectionNameProvider(),
        ),
        ChangeNotifierProvider<ProgramsProvider>( 
          create: (_) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<ExercisesProvider>(
          create: (_) => ExercisesProvider(),
        ),
        ChangeNotifierProvider<TrainingsProvider>(
          create: (_) => TrainingsProvider(),
        ),
        ChangeNotifierProvider<BlogProvider>(
          create: (_) => BlogProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<BottomNavigationProvider>(
          create: (_) => BottomNavigationProvider(),
        ),
        ChangeNotifierProvider<VerificationIdProvider>(
          create: (_) => VerificationIdProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Lines.top',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
            useMaterial3: true,
            colorScheme: lightColorScheme,
       fontFamily: 'SourceSerifPro'),
        darkTheme: ThemeData(
          appBarTheme: const AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
            useMaterial3: true,
            colorScheme: lightColorScheme,
            fontFamily: 'SourceSerifPro'),
        //home: const IntroScreen(),
        home: (isFirstBuild ? const IntroScreen() : const MainScreen(didFetch: false)),
      ),
    );
  }
}
