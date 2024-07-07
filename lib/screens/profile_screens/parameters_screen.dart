import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/calculate_parameters.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/fl_chart_files.dart';
import 'package:lines_top_mobile/screens/profile_screens/add_parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/control_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/programs_progress_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/register_parameters_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/list_items/indicator.dart';
import '../navigation_bar_screens/profile_screen.dart';

class ParametersScreen extends StatefulWidget {
  const ParametersScreen({super.key});
  static const routeName = 'profile/parameters';
  @override
  State<ParametersScreen> createState() => _ParametersScreenState();
}

class _ParametersScreenState extends State<ParametersScreen>
    with TickerProviderStateMixin {
  late UserProvider userData;
  late bool _isAdmin = false;
  int touchedDonutIndex = -1;
  int touchedPieIndex = -1;

  late AnimationController _titleAnimationController;
  late AnimationController _caloriesAnimationController;
  late AnimationController _bzuAnimationController;
  late AnimationController _distributionAnimationController;
  late AnimationController _restAnimationController;
  late AnimationController _helloAnimationController;

  late Animation<double> _helloOpacityAnimation;
  late Animation<Offset> _helloPositionAnimation;

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

  final TextEditingController _nameChangeController = TextEditingController();

  void _initAnimations() {
    _titleAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _caloriesAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _bzuAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _distributionAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _restAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _helloAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _helloPositionAnimation =
        Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _helloAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));
    _helloOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _helloAnimationController, curve: Curves.linearToEaseOut));

    _titlePositionAnimation =
        Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _titleAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));
    _titleOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _titleAnimationController, curve: Curves.linearToEaseOut));

    _caloriesOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _caloriesAnimationController,
            curve: Curves.linearToEaseOut));
    _caloriesPositionAnimation =
        Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _caloriesAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));

    _bzuScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _bzuAnimationController, curve: Curves.fastLinearToSlowEaseIn));
    _bzuOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _bzuAnimationController, curve: Curves.linearToEaseOut));

    _distributionScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _distributionAnimationController,
            curve: Curves.fastLinearToSlowEaseIn));
    _distributionOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _distributionAnimationController,
            curve: Curves.linearToEaseOut));
    _distributionPositionAnimation =
        Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _distributionAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));

    _restOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _restAnimationController, curve: Curves.linearToEaseOut));
    _restPositionAnimation =
        Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _restAnimationController,
                curve: Curves.fastLinearToSlowEaseIn));
  }

  void _startAnimtaions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _titleAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _helloAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _caloriesAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _bzuAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _distributionAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _restAnimationController.forward();
    _checkAndAskNewStats();
  }

  @override
  void initState() {
    userData = Provider.of<UserProvider>(context, listen: false);
    _initAnimations();
    _startAnimtaions();
    super.initState();
  }

  Widget _blurredChild({required Widget blurredChild, required Widget child}) {
    return Stack(
      children: [
        blurredChild,
        Center(
          heightFactor: 2,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8.0,
              sigmaY: 8.0,
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesStats() {
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
    print(distribution);
    var DISstrings = distribution.keys
        .map((key) => '$key - ${GetDistributionPercentages()[key]}% \n')
        .toList();
    var BZUWidgets = bzuStrings.keys
        .map((key) => bzuStrings[key]!
            .split('|')
            .map((part) => Text(part,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white)))
            .toList())
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SlideTransition(
            position: _caloriesPositionAnimation,
            child: FadeTransition(
                opacity: _caloriesOpacityAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Твоя дневная норма\n$calories ккал',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ))),
        SizedBox(
          height: 350,
          child: FadeTransition(
            opacity: _bzuOpacityAnimation,
            child: ScaleTransition(
              scale: _bzuScaleAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: PieChart(buildPieChartData(0, (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedDonutIndex = -1;
                                return;
                              }
                              touchedDonutIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          }, showingSections(touchedPieIndex, bzu, 140))),
                  ),
                  Wrap(
                    children: [
                      Indicator(
                        color: palette[0],
                        text: 'Белки',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[1],
                        text: 'Жиры',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[2],
                        text: 'Углеводы',
                        isSquare: true,
                      ),
                    ],
                  ),
                ],
              ),
              // child: SfCircularChart(
              //   borderWidth: 0,
              //   palette: const [
              //     Color.fromARGB(255, 249, 119, 162),
              //     Color.fromARGB(255, 254, 155, 188),
              //     Color.fromARGB(255, 250, 200, 217),
              //     Color.fromARGB(255, 255, 223, 233),
              //     Color(0xFFFF8FB5),
              //   ],
              //   margin: const EdgeInsets.all(0),
              //   series: [
              //     PieSeries(
              //       enableTooltip: true,
              //       animationDuration: 400,
              //       dataSource: bzu.keys
              //           .map((key) => ChartData(key, bzu[key]!))
              //           .toList(),
              //       xValueMapper: (data, _) => data.x,
              //       yValueMapper: (data, _) => data.y,
              //       dataLabelSettings: DataLabelSettings(
              //         textStyle: Theme.of(context)
              //             .textTheme
              //             .titleLarge!
              //             .copyWith(
              //                 color: Colors.white, fontWeight: FontWeight.bold),
              //         isVisible: true,
              //       ),
              //     ),
              //   ],
              //   legend: Legend(
              //     textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              //         color: Colors.white, fontWeight: FontWeight.bold),
              //     isVisible: true,
              //     position: LegendPosition.bottom,
              //     overflowMode: LegendItemOverflowMode.wrap,
              //   ),
              // ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        SlideTransition(
          position: _distributionPositionAnimation,
          child: FadeTransition(
            opacity: _distributionOpacityAnimation,
            child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 30),
                child: Column(
                  children: [
                    ...BZUWidgets.map((texts) => Stack(
                          children: [
                            Positioned(
                              left: 12,
                              child: texts[0],
                            ),
                            Center(
                              child: texts[1],
                            ),
                            Positioned(right: 30, child: texts[2])
                          ],
                        )).toList(),
                  ],
                )),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        SlideTransition(
          position: _distributionPositionAnimation,
          child: FadeTransition(
            opacity: _distributionOpacityAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Распределение суточной калорийности:\n',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${DISstrings[0]} ${DISstrings[1]} ${DISstrings[2]} ${DISstrings[3]} ${DISstrings[4]}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 360,
          child: FadeTransition(
            opacity: _bzuOpacityAnimation,
            child: ScaleTransition(
              scale: _distributionScaleAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: PieChart(buildPieChartData(80,
                        (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedDonutIndex = -1;
                          return;
                        }
                        touchedDonutIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    }, showingSections(touchedDonutIndex, distribution,60))),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Indicator(
                        color: palette[0],
                        text: 'Завтрак',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[1],
                        text: '2-ой завтрак',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[2],
                        text: 'Обед',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[3],
                        text: 'Полдник',
                        isSquare: true,
                      ),
                      Indicator(
                        color: palette[4],
                        text: 'Ужин',
                        isSquare: true,
                      ),
                    ],
                  ),
                ],
              ),
              //           child: SfCircularChart(
              //       palette: const [
              //         Color.fromARGB(255, 249, 119, 162),
              //         Color.fromARGB(255, 254, 155, 188),
              //         Color.fromARGB(255, 250, 200, 217),
              //         Color.fromARGB(255, 255, 223, 233),
              //         Color(0xFFFF8FB5),
              //       ],
              // margin: const EdgeInsets.all(0),
              // series: [
              //   DoughnutSeries(
              //     enableTooltip: true,
              //     animationDuration: 400,
              //     dataSource: distribution.keys.map((key) => ChartData(key, distribution[key]!)).toList(),
              //     xValueMapper: (data, _) => data.x,
              //     yValueMapper: (data, _) => data.y,
              //     dataLabelSettings:DataLabelSettings(textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible : true,),                ),
              // ],
              // legend: Legend(textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),isVisible: true,position: LegendPosition.bottom,overflowMode: LegendItemOverflowMode.wrap,height: '50%'),
              //           ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlAreaChart(
      {required LineChartData data, required String title}) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          data,
          duration: Duration(milliseconds: 1500),
          curve: Curves.fastLinearToSlowEaseIn,
        ),
      ),
    );
  }

  
  Widget _buildFlRest() {
    return SlideTransition(
      position: _restPositionAnimation,
      child: FadeTransition(
        opacity: _restOpacityAnimation,
        child: Column(
          children: [
            Text('Вес (кг)',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
            _buildFlAreaChart(
                data: buildChartData(
                    userData.statsDates!, userData.statistics!['weight']!),
                title: 'Вес (кг)'),
            Text('Обхват груди (см)',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
            _buildFlAreaChart(
                data: buildChartData(
                    userData.statsDates!, userData.statistics!['chest']!),
                title: 'Обхват груди (см)'),
            Text('Обхват талии (см)',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
            _buildFlAreaChart(
                data: buildChartData(
                    userData.statsDates!, userData.statistics!['waist']!),
                title: 'Обхват талии (см)'),
            Text('Обхват бедер (см)',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
            _buildFlAreaChart(
                data: buildChartData(
                    userData.statsDates!, userData.statistics!['thighs']!),
                title: 'Обхват бедер (см)'),
          ],
        ),
      ),
    );
  }


  AlertDialog _buildAskDialog(BuildContext ctx) {
    return AlertDialog(
      surfaceTintColor: Colors.black,
      backgroundColor: Colors.white70,
      content: Text(
        'Прошел месяц, пора обновить параметры!',
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: Colors.white),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .pushReplacementNamed(AddParametersScreen.routeName);
            },
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

  void _checkAndAskNewStats() {
    if (userData.statsDates!.isEmpty) {
      return;
    }
    List<String> strings = userData.statsDates!.last.split('.');
    DateTime date = DateTime(
      int.parse(strings[2]),
      int.parse(strings[1]),
      int.parse(strings[0]),
    );
    if (DateTime.now().difference(date).inDays > 30) {
      if (mounted) {
        showDialog(context: context, builder: (ctx) => _buildAskDialog(ctx));
      }
    }
  }

  @override
  void dispose() {
    _caloriesAnimationController.stop();
    _caloriesAnimationController.dispose();
    _titleAnimationController.stop();
    _titleAnimationController.dispose();
    _bzuAnimationController.stop();
    _bzuAnimationController.dispose();
    _distributionAnimationController.stop();
    _distributionAnimationController.dispose();
    _restAnimationController.stop();
    _restAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UserProvider>(context);
    //userData.statsDates = ['12.2.2024','13.2.2024'];
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(ProfileScreen.routeName, (route) => false);
        return Future.value(true);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/bg_13.jpg'),
                  fit: BoxFit.cover)),
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
                        'Мой профиль',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _helloPositionAnimation,
                  child: FadeTransition(
                    opacity: _helloOpacityAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (ctx) => Container(
                                    height: 170,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20)),
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.white70,
                                              Colors.white
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                'Введите новое имя',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium,
                                              )),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: 60,
                                            child: TextField(
                                              controller: _nameChangeController,
                                            )),
                                        ElevatedButton(
                                            onPressed: () {
                                              userData
                                                  .setName(_nameChangeController
                                                      .text)
                                                  .then((result) {
                                                ScaffoldMessenger.of(context)
                                                    .clearSnackBars();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                    result == ''
                                                        ? 'Успешно!'
                                                        : result,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  backgroundColor:
                                                      Colors.white70,
                                                ));
                                                if (result == '') {
                                                  userData.setName(
                                                      _nameChangeController
                                                          .text);
                                                }
                                              });
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Text(
                                              'Готово',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )),
                                      ],
                                    ),
                                  ));
                        },
                        child: Text(
                          'Привет, ${userData.username}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: userData.statsDates!.isNotEmpty
                    ? _buildCaloriesStats()
                    : _blurredChild(
                        blurredChild: _buildCaloriesStats(),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              RegisterParametersScreen.routeName,
                              arguments: [true, widget]),
                          child: Text(
                            'Заполнить данные, чтобы узнать статистику',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
              ),
              if (userData.statsDates!.isNotEmpty)
                SliverToBoxAdapter(
                  child: userData.statsDates!.length > 1
                      ? _buildFlRest()
                      : FadeTransition(
                          opacity: _restOpacityAnimation,
                          child: UnconstrainedBox(
                              child: Container(
                            padding: const EdgeInsets.all(12),
                            width: 250,
                            decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(32)),
                            child: Text(
                              'Графики появляются после 2-ух заполнений статистики',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.white),
                            ),
                          ))),
                ),
              SliverToBoxAdapter(
                  child: UnconstrainedBox(
                      child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AddParametersScreen.routeName),
                    child: Text(
                      'Обновить данные',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    )),
              ))),
              SliverToBoxAdapter(
                child: UnconstrainedBox(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(ProgramsProgressScreen.routeName),
                      child: Text(
                        'Посмотреть прогресс программ',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.white),
                      )),
                )),
              ),
              if (_isAdmin)
                SliverToBoxAdapter(
                  child: UnconstrainedBox(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(ControlScreen.routeName),
                        child: Text(
                          'Панель',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        )),
                  )),
                ),
              if (_isAdmin)
                SliverToBoxAdapter(
                  child: UnconstrainedBox(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                        onPressed: () => DBHelper.deleteTables(),
                        child: Text(
                          'delete tables',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        )),
                  )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
