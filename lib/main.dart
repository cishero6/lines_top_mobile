import 'package:flutter/material.dart';
import './providers/blog_provider.dart';
import 'package:flutter/services.dart'; // For rootBundle
import './providers/trainings_provider.dart';
import 'dart:convert'; // For jsonDecode
import './screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import './providers/programs_provider.dart';
import 'providers/bottom_navigation_provider.dart';
import 'providers/exercises_provider.dart';
import 'package:json_theme/json_theme.dart';
import './helpers/color_schemes.g.dart';

import 'providers/section_name_provider.dart';
import 'providers/user_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final themeStr =
      await rootBundle.loadString('assets/theme/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  var theme = ThemeDecoder.decodeThemeData(themeJson)!;
  runApp(MyApp(
    theme: theme,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({super.key, required this.theme});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        ChangeNotifierProvider<UserDataProvider>(
          create: (_) => UserDataProvider(),
        ),
        ChangeNotifierProvider<BottomNavigationProvider>(
          create: (_) => BottomNavigationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Lines.top',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            fontFamily: 'SourceSerifPro'),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            fontFamily: 'SourceSerifPro'),
        home: const MainScreen(),
      ),
    );
  }
}
