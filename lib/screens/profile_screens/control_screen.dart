import 'package:flutter/material.dart';

import '../../widgets/list_items/grid_icon_item.dart';
import '../control_panel_screens/add_screens/add_blog_post_screen.dart';
import '../control_panel_screens/add_screens/add_exercise_screen.dart';
import '../control_panel_screens/add_screens/add_program_screen.dart';
import '../control_panel_screens/add_screens/add_training_screen.dart';
import '../control_panel_screens/control_panel_screen.dart';
class ControlScreen extends StatelessWidget {
  static const routeName = '/profile/control';
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Управление',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SliverGrid(
              delegate: SliverChildListDelegate(
                [
                  GridIconItem(
                      icon: Icons.add,
                      text: 'Управление постами',
                      onTap: () => Navigator.of(context).pushNamed(
                          ControlPanelScreen.routeName,
                          arguments: [AddBlogPostScreen.routeName])),
                  GridIconItem(
                      icon: Icons.add,
                      text: 'Управление упражнениями',
                      onTap: () => Navigator.of(context).pushNamed(
                          ControlPanelScreen.routeName,
                          arguments: [AddExerciseScreen.routeName])),
                  GridIconItem(
                      icon: Icons.add,
                      text: 'Управление тренировками',
                      onTap: () => Navigator.of(context).pushNamed(
                          ControlPanelScreen.routeName,
                          arguments: [AddTrainingScreen.routeName])),
                  GridIconItem(
                      icon: Icons.add,
                      text: 'Управление программами',
                      onTap: () => Navigator.of(context).pushNamed(
                          ControlPanelScreen.routeName,
                          arguments: [AddProgramScreen.routeName])),
                ],
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2)),
        ],
      ),
    );
  }
}