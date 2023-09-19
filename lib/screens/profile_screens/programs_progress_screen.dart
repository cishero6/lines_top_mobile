import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../helpers/chart_data.dart';

class ProgramsProgressScreen extends StatefulWidget {
  const ProgramsProgressScreen({super.key});
  static const routeName = 'profile/programs_progress';
  @override
  State<ProgramsProgressScreen> createState() => _ProgramsProgressScreenState();
}

class _ProgramsProgressScreenState extends State<ProgramsProgressScreen> with TickerProviderStateMixin{
  late UserDataProvider authData;
  @override
  Widget build(BuildContext context) {
    authData = Provider.of<UserDataProvider>(context,listen: false);
    var progress = authData.progress!;
    var programs = Provider.of<ProgramsProvider>(context,listen: false).items;
    Map<String,double> progresses = {};
    for(var prName in progress.keys){
      var trainingsPr = progress[prName]!;
      double temp = 0;
      for (var element in trainingsPr) {temp += element;}
      temp = temp / (trainingsPr.length * 100);
      progresses.addAll({prName:temp});
    }
    


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_14.jpg'),fit: BoxFit.cover)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              title: Text('Мой прогресс',style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 500,
                child: SfCircularChart(
                                        palette: const [
                        Color.fromARGB(255, 249, 119, 162),
                        Color.fromARGB(255, 254, 155, 188),
                        Color.fromARGB(255, 255, 169, 198),
                        Color.fromARGB(255, 255, 123, 165),
                        Color(0xFFFF8FB5),
                      ],
                        margin: const EdgeInsets.all(0),
                        series: [
                          RadialBarSeries(
                            
                            maximumValue: 100,
                            enableTooltip: true,
                            animationDuration: 400,
                            dataSource: authData.progress!.keys.map((key) => ChartData(programs.singleWhere((element) => element.id == key).title, (progresses[key]! * 10000) ~/ 1 /100)).toList(),
                            xValueMapper: (data, _) => data.x,
                            yValueMapper: (data, _) => data.y,
                            dataLabelSettings:const DataLabelSettings(isVisible : true),
                          ),
                        ],
                        legend: Legend(position: LegendPosition.bottom,isVisible: true,overflowMode: LegendItemOverflowMode.wrap,textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
                      ),
                      
              ),
            ),],
        ),
      ),
    );
  }
}