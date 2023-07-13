import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyBottomNavigationBar({required this.navigatorKey,super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  final List<String> _routeNames = ['/blog','/profile','/blog','/programs'];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        selectedItemColor: Colors.black,
        elevation: 10,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined,color: Colors.black54),
              label: 'Блог',
              activeIcon: Icon(Icons.book_sharp,color: Color.fromRGBO(145,39,158, 1),)),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline,color: Colors.black54),
              label: 'Профиль',
              activeIcon: Icon(Icons.person,color: Color.fromRGBO(145,39,158, 1),)),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline,color: Colors.black54),
              label: 'Инфо',
              activeIcon: Icon(Icons.info,color: Color.fromRGBO(145,39,158, 1),)),
           BottomNavigationBarItem(
              icon: Icon(Icons.sports_gymnastics_outlined,color: Colors.black54,),
              label: 'Программы',
              activeIcon: Icon(Icons.sports_gymnastics,color: Color.fromRGBO(145,39,158, 1),)),
        ],
        onTap: (value) {
          setState(() {
              _currentIndex = value;
          });
          widget.navigatorKey.currentState!.pushReplacementNamed(_routeNames[value]);
        },
      );
  }
}