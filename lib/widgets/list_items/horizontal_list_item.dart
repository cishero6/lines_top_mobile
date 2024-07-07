
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HorizontalListItem extends StatefulWidget {
  final String title;
  final void Function() onPressed;
  final Duration waitTimer;
  final Widget? middleItem;
  late bool? goldenColor;
  HorizontalListItem(
      {required this.title, required this.onPressed,required this.waitTimer, this.middleItem,this.goldenColor,super.key});

  @override
  State<HorizontalListItem> createState() => _HorizontalListItemState();
}

class _HorizontalListItemState extends State<HorizontalListItem> with TickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;


  void _startAnimations()async{
    await Future.delayed(widget.waitTimer);
    // ignore: empty_catches
    try {_animationController.forward();} catch(e){}
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this,duration: const Duration(milliseconds: 600));
    _offsetAnimation = Tween(begin: const Offset(3, 0),end: const Offset(0,0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _opacityAnimation = Tween(begin: 0.0,end:1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _startAnimations();
    super.initState();
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        widget.goldenColor ??= false;

    return GestureDetector(
      onTap: widget.onPressed,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
            child: Card(
              color: widget.goldenColor! ? Color.fromARGB(116, 28, 74, 92) : Color.fromARGB(60, 0, 0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    if (widget.middleItem != null) widget.middleItem!,
                    const Icon(Icons.arrow_forward_ios,color: Colors.white,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
