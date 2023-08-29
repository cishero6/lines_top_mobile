import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/screens/profile_screens/parameters_screen.dart';
import 'package:provider/provider.dart';

class RegisterParametersScreen extends StatefulWidget {
  const RegisterParametersScreen({super.key});
  static const routeName = 'profile/parameters/register_parameters';
  @override
  State<RegisterParametersScreen> createState() => _RegisterParametersScreenState();
}

class _RegisterParametersScreenState extends State<RegisterParametersScreen> with TickerProviderStateMixin{
  final Duration _animationDuration = const Duration(milliseconds: 1200);

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _thighsController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  late String _activityAnswer;


  late TextButton _skipButton;
  late List<Widget> _forms;
  List<Widget> _pairWidgets = [];
  bool _flipped = false;
  bool _isAnimating = false;
  bool _firstBuild = true;
  int _currentIndex = -1;
  

  late AnimationController _animationController;
  late Animation<double> _firstFadeAnimation;
  late Animation<double> _secondFadeAnimation;
  late Animation<double> _firstScaleAnimation;
  late Animation<double> _secondScaleAnimation;
  late Animation<Offset> _firstOffsetAnimation;
  late Animation<Offset> _secondOffsetAnimation;


  void _switchAnimations(){
    if(_flipped){
      _firstScaleAnimation = Tween(begin: 1.0,end: 0.5).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstOffsetAnimation = Tween(begin: const Offset(0.0, 0.0),end: const Offset(0.0,-1.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstFadeAnimation = Tween(begin: 1.0,end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
      _secondScaleAnimation =  Tween(begin: 0.5,end: 1.0).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondOffsetAnimation = Tween(begin: const Offset(0.0, 3.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondFadeAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
    } else {
      _secondScaleAnimation = Tween(begin: 1.0,end: 0.5).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondOffsetAnimation = Tween(begin: const Offset(0.0, 0.0),end: const Offset(0.0,-1.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondFadeAnimation = Tween(begin: 1.0,end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
      _firstScaleAnimation =  Tween(begin: 0.5,end: 1.0).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstOffsetAnimation = Tween(begin: const Offset(0.0, 3.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstFadeAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
    }
    _animationController.reset();
    _flipped = !_flipped;
    setState(() {});
  }

  Widget _buildQuestionForm({required String question,required List<String> answers,required String answerVariable}) {
    return SizedBox(
      height: 500,
      child: Column(
        children: [
          Text(question,style: Theme.of(context).textTheme.headlineMedium,),
            ...answers.map(
            (answerOption) => TextButton(
              onPressed: () => setState(() {
                _activityAnswer = answerOption;
              }),
              child: Text(
                answerOption,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: _activityAnswer == answerOption ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
            ElevatedButton(
                onPressed: _pressNext,
                child: Text(
                  'Готово',
                  style: Theme.of(context).textTheme.titleSmall,
                )),
            const SizedBox(
              height: 30,
            ),
            _skipButton,
        ],
      ),
    );
  }

  Widget _buildAskForm({required String askText,required TextEditingController textEditingController}){
    return SizedBox(
        height: 400,
        child: Column(
          children: [
            Text(
              askText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              width: 80,
              child: Platform.isIOS
                  ? CupertinoTextField(
                      controller: textEditingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_)=>setState(() {}),
                    )
                  : TextField(
                      controller: textEditingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_)=>setState(() {}),
                    ),
            ),
            ElevatedButton(
                onPressed: _pressNext,
                child: Text(
                  'Готово',
                  style: Theme.of(context).textTheme.titleSmall,
                )),
            const SizedBox(
              height: 30,
            ),
            _skipButton,
          ],
        ),
      );
  }


  Future<void> _executeAnimations()async{
    if(mounted){
      _isAnimating = true;
      await _animationController.forward();
      _isAnimating = false;
    }
  }

  void _pressNext()async {
    if(_isAnimating) return;
    FocusManager.instance.primaryFocus!.unfocus();
    if(_currentIndex+2 >= _forms.length){
      var userData = Provider.of<UserDataProvider>(context,listen: false);
      num coefficient;
      switch (_activityAnswer) {
        case '◦ Спортом не занимаюсь':
          coefficient = 1.2;
          break;
        case '◦ Спортом не занимаюсь, но много хожу (почти каждый день около 10к шагов и больше)':
          coefficient = 1.3;
          break;
        case '◦ Занимаюсь спортом 1-2 раза в неделю':
          coefficient = 1.6;
          break;
        case '◦ Занимаюсь спортом 3-4 раза в неделю':
          coefficient = 1.7;
          break;
        case '◦ Занимаюсь спортом более 5 раз в неделю':
          coefficient = 1.9;
          break;
        default:
        coefficient = 1.2;
      }
      var result = await userData.updateStatistics({
        'age': [num.parse(_ageController.text)],
        'height': [num.parse(_heightController.text)],
        'weight': [num.parse(_weightController.text)],
        'activity': [coefficient],
        'chest': [num.parse(_chestController.text)],
        'waist': [num.parse(_waistController.text)],
        'thighs': [num.parse(_thighsController.text)]
      });
      if(result == 'Успешно!'){
        Navigator.of(context).pushReplacementNamed(ParametersScreen.routeName,arguments: [true,widget]);
      } else{
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result),backgroundColor: Colors.white70,));
      }
      return;
    }
    if(!_flipped) {
      _pairWidgets[1] = _forms[_currentIndex+2];
    }else{
      _pairWidgets[0] = _forms[_currentIndex+2];
    }
    setState(() {});
    _currentIndex++;
    await _executeAnimations();
    _switchAnimations();
  }

  _buildForms(){
    _forms = [
      _buildAskForm(askText: 'Введите ваш возраст',textEditingController: _ageController,),
      _buildAskForm(askText: 'Введите ваш рост',textEditingController: _heightController,),
      _buildAskForm(askText: 'Введите ваш вес', textEditingController: _weightController,),
      _buildAskForm(askText: 'Введите гр', textEditingController: _chestController,),
      _buildAskForm(askText: 'Введите бдр', textEditingController: _thighsController,),
      _buildAskForm(askText: 'Введите талия', textEditingController: _waistController),
      _buildQuestionForm(
          question: 'Твоя активность',
          answers: [
            '◦ Спортом не занимаюсь',
            '◦ Спортом не занимаюсь, но много хожу (почти каждый день около 10к шагов и больше)',
            '◦ Занимаюсь спортом 1-2 раза в неделю',
            '◦ Занимаюсь спортом 3-4 раза в неделю',
            '◦ Занимаюсь спортом более 5 раз в неделю',
          ],
          answerVariable: _activityAnswer),
    ];
  }

  _initializeVariabes(){
    _activityAnswer = '';
    _skipButton = TextButton(
        onPressed: _skip,
        child: Text(
          'Пропустить',
          style: Theme.of(context).textTheme.titleMedium,
        ));
    _buildForms();

  _pairWidgets = [_forms[0],_forms[1]];
  }
  @override
  void initState() {

    _animationController = AnimationController(duration: _animationDuration,vsync: this);
      _firstScaleAnimation = Tween(begin: 1.0,end: 0.5).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstOffsetAnimation = Tween(begin: const Offset(0.0, 0.0),end: const Offset(0.0,-1.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _firstFadeAnimation = Tween(begin: 1.0,end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
      _secondScaleAnimation =  Tween(begin: 0.5,end: 1.0).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondOffsetAnimation = Tween(begin: const Offset(0.0, 3.0),end: const Offset(0.0,0.0)).animate(CurvedAnimation(parent: _animationController,curve: Curves.fastLinearToSlowEaseIn));
      _secondFadeAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut));
    super.initState();
  }

  void _skip(){
      Navigator.of(context).pushReplacementNamed(ParametersScreen.routeName,arguments: [true,widget]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  


  @override
  Widget build(BuildContext context) {
    if(_firstBuild){
      _firstBuild = false;
    _initializeVariabes();
    }else{
      _buildForms();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration:const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_4.jpg'),opacity: 0.5,fit: BoxFit.cover)),
        child: Stack(children: [
          Center(child: FadeTransition(opacity: _firstFadeAnimation,child: ScaleTransition(scale: _firstScaleAnimation,child: SlideTransition(position: _firstOffsetAnimation,child: _pairWidgets[0])))),
          Center(child: FadeTransition(opacity: _secondFadeAnimation,child: ScaleTransition(scale: _secondScaleAnimation,child: SlideTransition(position: _secondOffsetAnimation,child: _pairWidgets[1])))),
        ],),
      ),
    );
  }
}