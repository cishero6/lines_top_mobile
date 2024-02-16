import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/program.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class ProgramsProgressScreen extends StatefulWidget {
  const ProgramsProgressScreen({super.key});
  static const routeName = 'profile/programs_progress';
  @override
  State<ProgramsProgressScreen> createState() => _ProgramsProgressScreenState();
}

class _ProgramsProgressScreenState extends State<ProgramsProgressScreen> with TickerProviderStateMixin{
  late UserProvider authData;
  int touchedIndex = -1;
   late Map<String, List<int>> progress;
    late List<Program> programs;
    Map<String,double> progresses = {};


    @override
  void initState() {
    authData = Provider.of<UserProvider>(context,listen: false);
   progress = authData.progress!;
   print(progress);
   programs =Provider.of<ProgramsProvider>(context,listen: false).items;
      for(var prName in progress.keys){
      var trainingsPr = progress[prName]!;
      double temp = 0;
      for (var element in trainingsPr) {temp += element;}
      temp = temp / (trainingsPr.length);
      progresses.addAll({prName:temp.ceilToDouble()});
    }
    
    super.initState();
  }

Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    text = Text(programs[value.toInt()].title,style: style,);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
  
BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= Color.fromARGB(255, 240, 76, 255);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.pink : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.pinkAccent)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Colors.white38,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

    List<BarChartGroupData> showingGroups() => List.generate(programs.length, (i) {
      return makeGroupData(i, progresses[programs[i].id]!, isTouched: i == touchedIndex);
      });

      BarChartData mainBarData() {
    return BarChartData(
        maxY: 100,
        minY: 0,
      //backgroundColor: Colors.black26,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            weekDay = programs[group.x].title;
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${(rod.toY - 1).toString()}%',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }






  @override
  Widget build(BuildContext context) {

 

    //authData.statistics!['weight'] = [60,56,55,55];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_30.jpg'),opacity: 0.6,fit: BoxFit.cover)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              title: Text('Мой прогресс',style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            //SliverToBoxAdapter(child: SizedBox(height: 50,),),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 500,
                child: BarChart(mainBarData()),
                // child: SfCircularChart(
                //                         palette: const [
                //         Color.fromARGB(255, 249, 119, 162),
                //         Color.fromARGB(255, 254, 155, 188),
                //         Color.fromARGB(255, 255, 169, 198),
                //         Color.fromARGB(255, 255, 123, 165),
                //         Color(0xFFFF8FB5),
                //       ],
                //         margin: const EdgeInsets.all(0),
                //         series: [
                //           RadialBarSeries(
                            
                //             maximumValue: 100,
                //             enableTooltip: true,
                //             animationDuration: 400,
                //             dataSource: authData.progress!.keys.map((key) => ChartData(programs.singleWhere((element) => element.id == key).title, (progresses[key]! * 10000) ~/ 1 /100)).toList(),
                //             xValueMapper: (data, _) => data.x,
                //             yValueMapper: (data, _) => data.y,
                //             dataLabelSettings:const DataLabelSettings(isVisible : true),
                //           ),
                //         ],
                //         legend: Legend(position: LegendPosition.bottom,isVisible: true,overflowMode: LegendItemOverflowMode.wrap,textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
                //       ),
                      
              ),
            ),],
        ),
      ),
    );
  }
}