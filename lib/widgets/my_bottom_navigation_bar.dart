import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/bottom_navigation_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/blog_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/programs_screen.dart';
import 'package:provider/provider.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyBottomNavigationBar({required this.navigatorKey,super.key});
  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  final List<String> _routeNames = [BlogScreen.routeName,ProfileScreen.routeName,BlogScreen.routeName,ProgramsScreen.routeName];
  int _currentIndex = 0;

  

  @override
  Widget build(BuildContext context) {
    _currentIndex = Provider.of<BottomNavigationProvider>(context).index;
    return Theme(
      data: ThemeData(canvasColor: Theme.of(context).colorScheme.primary),
      child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          elevation: 10,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                label: 'Блог',
                activeIcon: Icon(Icons.book_sharp)),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Профиль',
                activeIcon: Icon(Icons.person)),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                label: 'Инфо',
                activeIcon: Icon(Icons.info)),
             BottomNavigationBarItem(
                icon: Icon(Icons.sports_gymnastics_outlined),
                label: 'Программы',
                activeIcon: Icon(Icons.sports_gymnastics)),
          ],
          onTap: (value) {
            Provider.of<BottomNavigationProvider>(context,listen: false).setIndex(value);
            widget.navigatorKey.currentState!.pushReplacementNamed(_routeNames[value]);
          },
        ),
    );
  }
}