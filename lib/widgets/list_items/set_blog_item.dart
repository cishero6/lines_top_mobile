import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/bottom_navigation_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/all_sets_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/exercise_process_screen.dart';
import 'package:lines_top_mobile/screens/program_process_screens/load_set_screen.dart';
import 'package:provider/provider.dart';

import '../../helpers/parallax_flow_delegate.dart';
import '../../models/training.dart';

// ignore: must_be_immutable
class SetBlogItem extends StatefulWidget {
  late Training? set = null;
  late String? title;
  late String? subtext;
  SetBlogItem(this.set,{super.key});
  SetBlogItem.empty(this.title,this.subtext,{super.key});

  @override
  State<SetBlogItem> createState() => _SetBlogItemState();
}

class _SetBlogItemState extends State<SetBlogItem> {
    final GlobalKey _backgroundImageKey = GlobalKey();
    late String title;
    late String subtext;
    late File? image;
    late void Function() onTap;

    @override
  void initState() {
    if (widget.set != null) {
      title = widget.set!.title;
      subtext = widget.set!.description!;
      onTap = () {
        bool shouldLoad = false;
        for (var sectionName in widget.set!.sections.keys) {
          for (var ex in widget.set!.sections[sectionName]!) {
            if (ex.video == null) {
              shouldLoad = true;
              break;
            }
          }
        }
        shouldLoad
            ? Navigator.of(context).pushNamed(
                LoadSetScreen.routeName,
                arguments: [widget.set, widget.set!.sections.keys.first],
              )
            : Navigator.of(context).pushNamed(
                ExerciseProcessScreen.routeName,
                arguments: [
                  widget.set,
                  widget.set!.sections.keys.first,
                  null,
                  null,
                ],
              );
      };
    } else {
      title = widget.title!;
      subtext = widget.subtext!;
      onTap = () {Provider.of<BottomNavigationProvider>(context,listen:false).setIndex(3);Navigator.of(context).pushNamed(AllSetsScreen.routeName);};
    }
    super.initState();
  }



Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey
      ),
      children: [
        if(widget.set != null) FadeInImage(
            placeholder: const AssetImage(
                'assets/images/placeholders/grey_gradient.jpeg'),
            image: FileImage(widget.set!.image!),
            key: _backgroundImageKey,
            fit: BoxFit.cover,
            placeholderFit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 500),
          ),
        if(widget.set == null) Container(key: _backgroundImageKey,decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black,Color.fromARGB(255, 105, 105, 105)],begin: Alignment.topLeft,end: Alignment.bottomRight)),height: 300,),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.35,
            child: Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            _buildParallaxBackground(context),
            _buildGradient(),
            _buildTitleAndSubtitle(),
          ],),
        ),
      ),
    );
  }
}