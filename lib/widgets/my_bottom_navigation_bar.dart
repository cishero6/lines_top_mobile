import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/bottom_navigation_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/blog_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/programs_screen.dart';
import 'package:provider/provider.dart';

import '../screens/navigation_bar_screens/info_screen.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyBottomNavigationBar({required this.navigatorKey,super.key});
  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  final List<String> _routeNames = [BlogScreen.routeName,ProgramsScreen.routeName,ProfileScreen.routeName,InfoScreen.routeName,];
  int _currentIndex = 0;

  

  @override
  Widget build(BuildContext context) {
    _currentIndex = Provider.of<BottomNavigationProvider>(context).index;
    return Theme(
      data: ThemeData(canvasColor: Colors.white54),
      child: BottomNavigationBar(
          iconSize: 28,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          elevation: 10,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Главная',
                activeIcon: Icon(Icons.home)),
             BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Программы',
                activeIcon: Icon(Icons.fitness_center)),
            BottomNavigationBarItem(
                icon: Icon(Icons.face_3_outlined),
                label: 'Профиль',
                activeIcon: Icon(Icons.face_3_rounded)),
            BottomNavigationBarItem(
                icon: Icon(Icons.bubble_chart_outlined),
                label: 'Инфо',
                activeIcon: Icon(Icons.bubble_chart)),
          ],
          onTap: (value) {
            Provider.of<BottomNavigationProvider>(context,listen: false).setIndex(value);
            widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(_routeNames[value], (route) => false);
          },
        ),
    );
  }
}