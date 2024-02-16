import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/program.dart';

import '../../helpers/parallax_flow_delegate.dart';
import '../../screens/details_screens/program_details_screen.dart';
import '../../screens/program_process_screens/trainings_list_screen.dart';

class ProgramListItem extends StatefulWidget {
  final Program program;
  const ProgramListItem(this.program, {super.key});

  @override
  State<ProgramListItem> createState() => _ProgramListItemState();
}

class _ProgramListItemState extends State<ProgramListItem> {
  final GlobalKey _backgroundImageKey = GlobalKey();


  void _pressCard(){
      Navigator.of(context).pushNamed(TrainingsListScreen.routeName,
          arguments: [widget.program]);
  }

  void _pressStart(){
    // if (!Provider.of<UserDataProvider>(context,listen: false).isAuth) {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: Colors.white70,
    //       content: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           Text(
    //             'Вы не вошли в аккаунт!',
    //             style: Theme.of(context).textTheme.bodyMedium,
    //           ),
    //           TextButton(
    //               onPressed: () {
    //                 Navigator.of(context)
    //                     .pushReplacementNamed(ProfileScreen.routeName);
    //                 ScaffoldMessenger.of(context).clearSnackBars();
    //                 Provider.of<BottomNavigationProvider>(context,
    //                         listen: false)
    //                     .setIndex(2);
    //               },
    //               child: Text(
    //                 'Войти',
    //                 style: Theme.of(context).textTheme.bodyMedium,
    //               ),),
    //         ],
    //       ),
    //     ),
    //   );
    //   return;
    // }
    Navigator.of(context).pushNamed(TrainingsListScreen.routeName,arguments: [widget.program]);
  }

  void _pressDetails() {
    Navigator.of(context).pushNamed(ProgramDetailsScreen.routeName,
          arguments: [widget.program]);
  }





  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
        delegate: ParallaxFlowDelegate(
          scrollable: Scrollable.of(context),
          listItemContext: context,
          backgroundImageKey: _backgroundImageKey,
          isHorizontal: true,
        ),
        children: [
          /*FadeInImage(
            placeholder: const AssetImage(
                'assets/images/placeholders/grey_gradient.jpeg'),
            image: FileImage(widget.program.image),
            key: _backgroundImageKey,
            fit: BoxFit.cover,
            placeholderFit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 500),
          ),*/
          if (widget.program.image == null)
            Image.asset('assets/content/programs/${widget.program.id}',key: _backgroundImageKey,fit: BoxFit.cover,),
          if (widget.program.image != null)
            Image.file(
              widget.program.image!,
              key: _backgroundImageKey,
              fit: BoxFit.cover,
            ),
        ]);
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return InkWell(
      onTap: _pressCard,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  widget.program.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  widget.program.subtext,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.white60),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)))),
                    onPressed: _pressDetails,
                    child: Text(
                      'Подробнее',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.white60),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)))),
                    onPressed: _pressStart,
                    child: Text(
                      'Начать',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          _buildParallaxBackground(context),
          _buildGradient(),
          _buildTitleAndSubtitle(),
        ]),
      ),
    );
  }
}
