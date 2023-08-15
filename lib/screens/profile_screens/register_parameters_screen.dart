import 'dart:io' show Platform;

import 'package:flutter/material.dart';

class RegisterParametersScreen extends StatefulWidget {
  const RegisterParametersScreen({super.key});

  @override
  State<RegisterParametersScreen> createState() => _RegisterParametersScreenState();
}

class _RegisterParametersScreenState extends State<RegisterParametersScreen> with TickerProviderStateMixin{
  final Duration _animationDuration = const Duration(milliseconds: 600);

  Widget _buildFirstForm(){
    AnimationController _initAnimationController = AnimationController(duration: _animationDuration,vsync: this);
    AnimationController _closeAnimationController = AnimationController(duration: _animationDuration,vsync: this);
    Animation<Offset> _initOffsetAnimation = Tween(begin: const Offset(1.0, 0.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _initAnimationController,curve: Curves.easeIn)); 
    Animation<Offset> _closeOffsetAnimation = Tween(begin: const Offset(0.0, 0.0),end: const Offset(-1.0,0.0)).animate(CurvedAnimation(parent: _closeAnimationController,curve: Curves.easeIn)); 
    Animation<double> _initScaleAnimation = Tween(begin: 0.5,end: 1.0).animate(CurvedAnimation(parent: _initAnimationController,curve: Curves.easeIn));
    Animation<double> _closeScaleAnimation = Tween(begin: 1.0,end: 0.5).animate(CurvedAnimation(parent: _closeAnimationController,curve: Curves.easeIn));

    return Container();


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: _buildFirstForm(),
      ),
    );
  }
}