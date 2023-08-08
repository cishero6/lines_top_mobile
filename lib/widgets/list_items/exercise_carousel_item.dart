import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';


class ExerciseCarouselItem extends StatefulWidget {
  final Exercise exercise;
  const ExerciseCarouselItem(this.exercise,{super.key});

  @override
  State<ExerciseCarouselItem> createState() => _ExerciseCarouselItemState();
}

class _ExerciseCarouselItemState extends State<ExerciseCarouselItem> with TickerProviderStateMixin{
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;


  
    void _startAnimations()async{

    _videoController = VideoPlayerController.file(widget.exercise.video!,videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    _chewieController = ChewieController(
      customControls: const CupertinoControls(backgroundColor: CupertinoColors.systemGrey, iconColor: Colors.black),
      placeholder: Container(color: Colors.black87),
      allowedScreenSleep: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      videoPlayerController: _videoController,
      aspectRatio: 16/9,
      autoInitialize: true,
      autoPlay: false,
      showControls: true,
    );
    _chewieController.addListener(() {
      if (_chewieController.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
         SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });

    await Future.delayed(const Duration(milliseconds:400));
    // ignore: empty_catches
    try {_animationController.forward();} catch(e){}
  }

 
  @override
  void initState() {
    
    _animationController = AnimationController(vsync: this,duration:const Duration(milliseconds: 600));
    _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _slideAnimation = Tween(begin:const Offset(0.0,1.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _startAnimations();
  
    super.initState();
  }

 @override
  void dispose() {
    _animationController.dispose();
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Flexible(flex: 3,fit: FlexFit.tight,child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: FittedBox(fit: BoxFit.scaleDown,child: Text(widget.exercise.title,style: Theme.of(context).textTheme.headlineMedium,)),
        ),),
        Flexible(flex:10,fit: FlexFit.loose,child: Container(color: Colors.black,child: AspectRatio(aspectRatio: _chewieController.aspectRatio!,child: Chewie(controller: _chewieController),),),),
        const Divider(thickness: 2,),
        Flexible(flex: 6,fit: FlexFit.tight,child: SlideTransition(position: _slideAnimation,child: FadeTransition(opacity: _opacityAnimation,child: Padding(
          padding: const EdgeInsets.only(top: 0,left: 20,right: 20),
          child: SingleChildScrollView(child: Text(widget.exercise.description,style: Theme.of(context).textTheme.titleLarge,)),
        ),),),),
        const Divider(thickness: 2,),
      ],),
    );
  }
}