import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/bottom_navigation_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/trainings_list_screen.dart';
import '../../models/program.dart';
import '../../screens/details_screens/program_details_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';

class ProgramListItem extends StatefulWidget {
  final double? width;
  final Program program;

  ProgramListItem(
      this.program,
      {this.width});
  @override
  State<ProgramListItem> createState() => _ProgramListItemState();
}

class _ProgramListItemState extends State<ProgramListItem> {  

  void _tryStart(){
    if (Provider.of<UserDataProvider>(context,listen: false).isAuth) {
      Navigator.of(context).pushNamed(TrainingsListScreen.routeName,arguments: [widget.program]);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).cardColor,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Вы не вошли в аккаунт!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ProfileScreen.routeName);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Provider.of<BottomNavigationProvider>(context,
                            listen: false)
                        .setIndex(1);
                  },
                  child: Text(
                    'Войти',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ))
            ],
          ),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40)),
      padding: const EdgeInsets.only(bottom: 8),
      width: widget.width ?? double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //Flexible(flex: 6,child: Image.network(widget.imageUrl,width: double.infinity,),),
            Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                child: Image.file(widget.program.image,fit: BoxFit.cover,width: double.infinity,) ),
          ),
          Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.program.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.program.subtext,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 6,
              ),
            ),
          ),
          Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)))),
                      onPressed: (){
                        Navigator.of(context).pushNamed(ProgramDetailsScreen.routeName,arguments: [widget.program]);
                      },
                      child: Text(
                        'Подробнее',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)))),
                      onPressed: _tryStart,
                      child: Text(
                        'Начать',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
