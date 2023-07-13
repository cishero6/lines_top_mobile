import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screens/auth_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screens/control_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<UserDataProvider>(context);
    if(!authData.isAuth){
      return const AuthScreen();
    } else {
      return const ControlScreen();
    }
  }
}
