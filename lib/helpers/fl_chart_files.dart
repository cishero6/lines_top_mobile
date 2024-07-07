 import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<Color> gradientColors = [
    Color.fromARGB(255, 255, 81, 246),
    Color.fromARGB(255, 255, 66, 205),
  ];

List<int> makeIntsFromDates(List<String> dates){
  List<DateTime> dateTimes = [];
  for(int i =0;i<dates.length;i++){
      List<String> strings = dates[i].split('.');
      DateTime date = DateTime(
            int.parse(strings[2]),
            int.parse(strings[1]),
            int.parse(strings[0]),
          );
      dateTimes.add(date);
  }
  List<int> listOfInts = [];
  for(int i =0;i<dateTimes.length;i++){
      listOfInts.add(dateTimes[i].difference(dateTimes.first).inDays);
  }
  return listOfInts;
}

LineChartData buildChartData(List<String> dates,List<num> values) {
    List<int> xValues = makeIntsFromDates(dates);
    List<num> yValues = values;
    num minY=1200;
    for (var value in yValues){
      if (value < minY){
        minY = value;
      }
    }
    List<FlSpot> data = [];
    for(int i = 0;i<xValues.length;i++){
      data.add(FlSpot(xValues[i].toDouble(), yValues[i].toDouble()));
    }
    return LineChartData(
      minY: minY.toDouble()-3,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            //getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            //getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      maxX: xValues.last+1,
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
        List<Color> palette =const [
                    Color.fromARGB(255, 249, 119, 162),
                    Color.fromARGB(255, 254, 155, 188),
                    Color.fromARGB(255, 250, 200, 217),
                    Color.fromARGB(255, 255, 223, 233),
                    Color(0xFFFF8FB5),
                  ];

    List<PieChartSectionData> showingSections(int touchedDonutIndex,Map<String,num> distribution,double radius) {

      List<String> names = [];
      List<num> values= [];
      distribution.forEach((key, value) {names.add(key);values.add(value);});
    return List.generate(distribution.keys.length, (i) {
      final isTouched = i == touchedDonutIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      radius = isTouched ? radius+10 : radius;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: palette[0],
            value: values[0].toDouble(),
            title: '${values[0].toDouble()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: palette[1],
            value: values[1].toDouble(),
            title: '${values[1].toDouble()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: palette[2],
            value: values[2].toDouble(),
            title: '${values[2].toDouble()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: palette[3],
            value: values[3].toDouble(),
            title: '${values[3].toDouble()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: palette[4],
            value: values[4].toDouble(),
            title: '${values[4].toDouble()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color:Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  PieChartData buildPieChartData(double centerSpaceRadius,void Function(FlTouchEvent event,PieTouchResponse? pieTouchResponse) touchCallBack,List<PieChartSectionData>? sections){
  return PieChartData(
    pieTouchData: PieTouchData(
      touchCallback: touchCallBack,
    ),
    borderData: FlBorderData(
      show: false,
    ),
    sectionsSpace: 0,

    centerSpaceRadius: centerSpaceRadius,
    sections: sections,
  );
  
  }

  
  