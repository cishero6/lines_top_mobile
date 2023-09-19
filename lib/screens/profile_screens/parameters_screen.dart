import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/calculate_parameters.dart';
import 'package:lines_top_mobile/helpers/chart_data.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/screens/profile_screens/add_parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/register_parameters_screen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../navigation_bar_screens/profile_screen.dart';

class ParametersScreen extends StatefulWidget {
  const ParametersScreen({super.key});
  static const routeName = 'profile/parameters';
  @override
  State<ParametersScreen> createState() => _ParametersScreenState();
}

class _ParametersScreenState extends State<ParametersScreen> with TickerProviderStateMixin {
  late UserDataProvider userData;


  late AnimationController _titleAnimationController;
  late AnimationController _caloriesAnimationController;
  late AnimationController _bzuAnimationController;
  late AnimationController _distributionAnimationController;
  late AnimationController _restAnimationController;

  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titlePositionAnimation;

  late Animation<double> _caloriesOpacityAnimation;
  late Animation<Offset> _caloriesPositionAnimation;

  late Animation<double> _bzuScaleAnimation;
  late Animation<double> _bzuOpacityAnimation;

  late Animation<double> _distributionScaleAnimation;
  late Animation<double> _distributionOpacityAnimation;
  late Animation<Offset> _distributionPositionAnimation;

  late Animation<double> _restOpacityAnimation;
  late Animation<Offset> _restPositionAnimation;


  void _initAnimations(){
    _titleAnimationController = AnimationController(duration: const Duration(milliseconds: 1000),vsync: this);
    _caloriesAnimationController = AnimationController(duration: const Duration(milliseconds: 1200),vsync: this);
    _bzuAnimationController = AnimationController(duration: const Duration(milliseconds: 1000),vsync: this);
    _distributionAnimationController = AnimationController(duration: const Duration(milliseconds: 1000),vsync: this);
    _restAnimationController = AnimationController(duration: const Duration(milliseconds: 1000),vsync: this);

    _titlePositionAnimation = Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _titleAnimationController,curve: Curves.fastLinearToSlowEaseIn));
    _titleOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _titleAnimationController, curve: Curves.linearToEaseOut));

    _caloriesOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _caloriesAnimationController, curve: Curves.linearToEaseOut));
    _caloriesPositionAnimation = Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _caloriesAnimationController,curve: Curves.fastLinearToSlowEaseIn));

    _bzuScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bzuAnimationController, curve: Curves.fastLinearToSlowEaseIn));
    _bzuOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bzuAnimationController, curve: Curves.linearToEaseOut));


    _distributionScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _distributionAnimationController, curve: Curves.fastLinearToSlowEaseIn));
    _distributionOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _distributionAnimationController, curve: Curves.linearToEaseOut));
    _distributionPositionAnimation = Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _distributionAnimationController,curve: Curves.fastLinearToSlowEaseIn));

    _restOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _restAnimationController, curve: Curves.linearToEaseOut));
    _restPositionAnimation = Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _restAnimationController,curve: Curves.fastLinearToSlowEaseIn));
  }


  void _startAnimtaions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if(mounted)_titleAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if(mounted)_caloriesAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if(mounted)_bzuAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if(mounted)_distributionAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if(mounted)_restAnimationController.forward();
    _checkAndAskNewStats();
  }

  @override
  void initState() {
    _initAnimations();
    _startAnimtaions();
    super.initState();
  }

  Widget _blurredChild({required Widget blurredChild, required Widget child}){
    return Stack(
      children: [
        blurredChild,
        Center(
          heightFactor: 2,
          child: BackdropFilter(filter: ImageFilter.blur(
              sigmaX: 8.0,
              sigmaY: 8.0,
            ),child: child,),
        ),
      ],
    );
  }

  Widget _buildCaloriesStats(){
    var calories = CalculateGeneralCalories(
        age: userData.statistics!['age']!.isNotEmpty
            ? userData.statistics!['age']!.last
            : 20,
        height: userData.statistics!['height']!.isNotEmpty
            ? userData.statistics!['height']!.last
            : 170,
        weight: userData.statistics!['weight']!.isNotEmpty
            ? userData.statistics!['weight']!.last
            : 55,
        coefficient: userData.statistics!['activity']!.isNotEmpty
            ? userData.statistics!['activity']!.last
            : 1.2);
    var bzu = CalculateBZU(calories: calories);
    var bzuStrings = CalculateBZUStrings(calories: calories);
    var distribution = CalculateDistribution(calories: calories);
    var DISstrings = distribution.keys.map((key) => '$key - ${GetDistributionPercentages()[key]}% \n').toList();
     var BZUWidgets = bzuStrings.keys.map((key) => bzuStrings[key]!.split('|').map((part) => Text(part,style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white))).toList()).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      SlideTransition(position: _caloriesPositionAnimation,child: FadeTransition(opacity: _caloriesOpacityAnimation,child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text('Твоя дневная норма\n$calories ккал',textAlign: TextAlign.center,style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),),
      ))),
      SizedBox(
        height: 350,
        child: FadeTransition(
          opacity: _bzuOpacityAnimation,
          child: ScaleTransition(
            scale: _bzuScaleAnimation,
            child: SfCircularChart(
              borderWidth: 0,
              palette: const [
                    Color.fromARGB(255, 249, 119, 162),
                    Color.fromARGB(255, 254, 155, 188),
                    Color.fromARGB(255, 250, 200, 217),
                    Color.fromARGB(255, 255, 223, 233),
                    Color(0xFFFF8FB5),
                  ],
              margin: const EdgeInsets.all(0),
              series: [
                PieSeries(
                  
                  enableTooltip: true,
                  animationDuration: 400,
                  dataSource: bzu.keys.map((key) => ChartData(key, bzu[key]!)).toList(),
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  dataLabelSettings:DataLabelSettings(textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible : true,),
                ),
              ],
              legend: Legend(textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible: true,position: LegendPosition.bottom,overflowMode: LegendItemOverflowMode.wrap,), 
            ),
          ),
        ),
      ),
      const SizedBox(height: 30,),
      SlideTransition(position: _distributionPositionAnimation,child: FadeTransition(opacity: _distributionOpacityAnimation,child: Padding(
              padding: const EdgeInsets.only(top: 15,left: 30),
              child: Column(children: [
                ...BZUWidgets.map((texts) => Stack(children: [Positioned(left: 12,child: texts[0],),Center(child: texts[1],),Positioned(right: 30,child: texts[2])],)).toList(),
              ],)
      ),),),
            const SizedBox(height: 30,),

      SlideTransition(position: _distributionPositionAnimation,child: FadeTransition(opacity: _distributionOpacityAnimation,child: Padding(
              padding: const EdgeInsets.only(top: 15,left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Распределение суточной калорийности:\n',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
                  Text('${DISstrings[0]} ${DISstrings[1]} ${DISstrings[2]} ${DISstrings[3]} ${DISstrings[4]}',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
                ],
              ),
      ),),),
              SizedBox(
                height: 450,
                child: FadeTransition(
                        opacity: _bzuOpacityAnimation,
                        child: ScaleTransition(
                          scale: _distributionScaleAnimation,
                          child: SfCircularChart(
                      palette: const [
                        Color.fromARGB(255, 249, 119, 162),
                        Color.fromARGB(255, 254, 155, 188),
                        Color.fromARGB(255, 250, 200, 217),
                        Color.fromARGB(255, 255, 223, 233),
                        Color(0xFFFF8FB5),
                      ],
                margin: const EdgeInsets.all(0),
                series: [
                  DoughnutSeries(
                    enableTooltip: true,
                    animationDuration: 400,
                    dataSource: distribution.keys.map((key) => ChartData(key, distribution[key]!)).toList(),       
                    xValueMapper: (data, _) => data.x,
                    yValueMapper: (data, _) => data.y,
                    dataLabelSettings:DataLabelSettings(textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible : true,),                ),
                ],
                legend: Legend(textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible: true,position: LegendPosition.bottom,overflowMode: LegendItemOverflowMode.wrap,height: '50%'), 
                          ),
                        ),
                      ),
              ),
    ],);
  }

  Widget _buildAreaChart({required List<ChartData> chartData,required String title}){

    if(chartData.last.x != DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)){
      chartData.add(ChartData(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day), null));
    }
    return SfCartesianChart(
      
        title: ChartTitle(text: title,textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
        primaryYAxis: NumericAxis(labelFormat: '{value}'),
        primaryXAxis: DateTimeAxis(),
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true),
        series: <ChartSeries>[
          // Renders area chart
          AreaSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color.fromARGB(45, 233, 30, 98),
                  Color.fromARGB(144, 233, 30, 98),
                  Colors.pink
                ],
                stops: [
                  0.0,
                  0.5,
                  1.0
                ]),
          )
        ]);
  }


  Widget _buildRest(){
    List<ChartData> weightChartData = [];
    List<ChartData> waistChartData = [];
    List<ChartData> thighsChartData = [];
    List<ChartData> chestChartData = [];
    for(int i =0;i<userData.statsDates!.length;i++){
      List<String> strings = userData.statsDates![i].split('.');
      DateTime date = DateTime(
            int.parse(strings[2]),
            int.parse(strings[1]),
            int.parse(strings[0]),
          );
      weightChartData.add(
        ChartData(
          date,
          userData.statistics!['weight']![i] == -1
              ? null
              : userData.statistics!['weight']![i],
        ),
      );
      waistChartData.add(
        ChartData(
          date,
          userData.statistics!['waist']![i] == -1
              ? null
              : userData.statistics!['waist']![i],
        ),
      );
      chestChartData.add(
        ChartData(
          date,
          userData.statistics!['chest']![i] == -1
              ? null
              : userData.statistics!['chest']![i],
        ),
      );
      thighsChartData.add(
        ChartData(
          date,
          userData.statistics!['thighs']![i] == -1
              ? null
              : userData.statistics!['thighs']![i],
        ),
      );
    }


    return SlideTransition(
      position: _restPositionAnimation,
      child: FadeTransition(
        opacity: _restOpacityAnimation,
        child: Column(
          children: [
            _buildAreaChart(chartData: waistChartData, title: 'Вес (кг)'),
           _buildAreaChart(chartData: chestChartData, title: 'Обхват груди (см)'),
            _buildAreaChart(chartData: waistChartData, title: 'Обхват талии (см)'),
            _buildAreaChart(chartData: thighsChartData, title: 'Обхват бёдер (см)')
          ],
        ),
      ),
    );
  }

  AlertDialog _buildAskDialog(BuildContext ctx){
    return AlertDialog(
      surfaceTintColor: Colors.black,
      backgroundColor: Colors.white70,
      content: Text('Прошел месяц, пора обновить параметры!',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx)
                .pushReplacementNamed(AddParametersScreen.routeName),
            child: Text(
              'Обновить',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white),
            )),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Позже',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white),
            ))
      ],
    );
  }

  void _checkAndAskNewStats(){
    if(userData.statsDates!.isEmpty){
      return;
    }
    List<String> strings = userData.statsDates!.last.split('.');
      DateTime date = DateTime(
            int.parse(strings[2]),
            int.parse(strings[1]),
            int.parse(strings[0]),
          );
    if(DateTime.now().difference(date).inDays > 30){
      if(mounted){
      showDialog(context: context, builder: (ctx)=>_buildAskDialog(ctx));
      }
    }
  }


  @override
  void dispose() {
    _caloriesAnimationController.dispose();
    _titleAnimationController.dispose();
    _bzuAnimationController.dispose();
    _distributionAnimationController.dispose();
    _restAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    userData= Provider.of<UserDataProvider>(context);
    print(userData);
    return WillPopScope(
      onWillPop: () {Navigator.of(context).pushNamedAndRemoveUntil(ProfileScreen.routeName, (route) => false);return Future.value(true);},
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_13.jpg'),fit: BoxFit.cover)),
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.white,
                title: FadeTransition(
                  opacity: _titleOpacityAnimation,
                  child: SlideTransition(
                    position: _titlePositionAnimation,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Мои параметры',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: userData.statsDates!.isNotEmpty ? _buildCaloriesStats() : _blurredChild(blurredChild: _buildCaloriesStats(), child: ElevatedButton(onPressed: ()=>Navigator.of(context).pushNamed(RegisterParametersScreen.routeName,arguments: [true,widget]),child: Text('Заполнить данные, чтобы узнать статистику',style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),),),),),
              if(userData.statsDates!.isNotEmpty) SliverToBoxAdapter(child: userData.statsDates!.length > 1 ? _buildRest() : FadeTransition(opacity: _restOpacityAnimation,child: UnconstrainedBox(child: Container(padding: const EdgeInsets.all(12),width: 250,decoration: BoxDecoration(color: Colors.black26,borderRadius: BorderRadius.circular(32)),child: Text('Графики появляются после 2-ух заполнений статистики',textAlign: TextAlign.center,style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),),))),),
              SliverToBoxAdapter(child: UnconstrainedBox(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: ()=> Navigator.of(context).pushNamed(AddParametersScreen.routeName), child: Text('Обновить данные',style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),)),
              ))),
          ],),
        ),
      ),
    );
  }
}