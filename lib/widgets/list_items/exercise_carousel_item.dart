import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';


class ExerciseCarouselItem extends StatefulWidget {
  final Exercise exercise;
  final int repId;
  const ExerciseCarouselItem(this.exercise,{required this.repId,super.key});

  @override
  State<ExerciseCarouselItem> createState() => _ExerciseCarouselItemState();
}

class _ExerciseCarouselItemState extends State<ExerciseCarouselItem> with TickerProviderStateMixin{
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;


  List<bool> _checkMarks = [];

  void turnOffVideo()async{
    _videoController.pause();
  }
  
    void _startAnimations()async{

      if(widget.exercise.video == null){
        _videoController = VideoPlayerController.asset('assets/content/exercises/${widget.exercise.id}.mov',videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
      }else{
        _videoController = VideoPlayerController.file(widget.exercise.video!,videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
      }
    _chewieController = ChewieController(
      showControlsOnInitialize: true,
      allowMuting: true,
      hideControlsTimer: const Duration(milliseconds: 1500),
      customControls: const CupertinoControls(backgroundColor: Color.fromARGB(117, 142, 142, 147), iconColor: Colors.black),
      placeholder: Container(color: Colors.black),
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
    if(mounted){
      _animationController.forward();
    }
  }

 
  @override
  void initState() {
    _animationController = AnimationController(vsync: this,duration:const Duration(milliseconds: 600));
    _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _slideAnimation = Tween(begin:const Offset(0.0,1.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _startAnimations();
    _checkMarks = List.generate(widget.exercise.exerciseListTexts[widget.repId].split('\n').length, (index) => false);
    super.initState();
  }

 @override
  void dispose() {
    _animationController.dispose();
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildExerciseRepetitionTable(){
    List<String> exercisesList = widget.exercise.exerciseListTexts[widget.repId].split('\n');
    List<String> repetitionsList = widget.exercise.repetitionListTexts[widget.repId].split('\n');
    List<Widget> tableList = [];
    for(int i = 0;i<exercisesList.length;i++){
      tableList.add(GestureDetector(
        onTap: ()=>setState(()=>_checkMarks[i] = !_checkMarks[i]),
        child: Row(
          children: [
            Checkbox(
              value: _checkMarks[i],
              onChanged: (_) =>setState(()=>_checkMarks[i] = !_checkMarks[i]),
              activeColor: Colors.white,
                  ),
            Text(
              exercisesList[i],
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right:32.0),
                child: Text(
                  repetitionsList[i],
                  textAlign: TextAlign.end,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ));
      
    }

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Упражнения',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Кол-во повторений',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white54),
              ),
            ),
          ],
      ),
      ...tableList,
    ],
      );
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(children: [
          const SizedBox(height: 100,),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(widget.exercise.title,style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
          ),
          Container(color: Colors.black,child: AspectRatio(aspectRatio: _chewieController.aspectRatio!,child: Chewie(controller: _chewieController),),),
          SlideTransition(position: _slideAnimation,child: FadeTransition(opacity: _opacityAnimation,child: Padding(
            padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
            child: Text(widget.exercise.description,style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
          ),),),
          _buildExerciseRepetitionTable(),
        ],),
      ),
    );
  }
}