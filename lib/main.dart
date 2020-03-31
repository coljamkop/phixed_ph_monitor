import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'pHixed',
      theme: ThemeData.dark(),
      home: MyHomePage(
        title: 'pHixed pH Monitor System',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Color> gradientColors = [
    Colors.blue,
    Colors.orange,
  ];

  bool isReading = true;

  List<FlSpot> data = [
    FlSpot(0, 0),
  ];

  Random rng = new Random();

  Stream<double> timedCounter(Duration interval, [int maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      if (isReading) {
        yield rng.nextInt(15) + rng.nextDouble();
      }
      i++;
      if (i == maxCount) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("pHixed pH Monitor")),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            isReading = !isReading;
          },
          child: isReading ? Icon(Icons.stop) : Icon(Icons.play_arrow)),
      body: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: timedCounter(Duration(milliseconds: 500)),
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    int max = 12;
                    var newVal = snapshot.data;
                    if (data.length == max) {
                      List<FlSpot> temp = data
                          .sublist(1)
                          .map((e) => FlSpot(e.x - 1, e.y))
                          .toList();
                      data.removeRange(0, data.length);
                      temp.add(FlSpot(temp.length.roundToDouble(), newVal));
                      data.addAll(temp);
                    } else {
                      data.add(FlSpot(data.length.roundToDouble(), newVal));
                    }
                    return LineChart(mainData());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: getGridData(),
      titlesData: getTitlesData(),
      borderData: getBorderData(),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 15,
      lineBarsData: getLineBarsData(),
    );
  }

  List<LineChartBarData> getLineBarsData() {
    return [
      LineChartBarData(
        spots: data,
        isCurved: false,
        colors: gradientColors,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ];
  }

  FlBorderData getBorderData() {
    return FlBorderData(
        show: true, border: Border.all(color: Colors.grey, width: 1));
  }

  FlTitlesData getTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        textStyle: TextStyle(
            color: const Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 16),
        getTitles: (value) {
          return '';
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        textStyle: TextStyle(
          color: const Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        getTitles: (value) {
          switch (value.toInt()) {
            case 0:
              return '0 pH';
            case 7:
              return '7 pH';
            case 14:
              return '14 pH';
          }
          return '';
        },
        reservedSize: 35,
        margin: 12,
      ),
    );
  }

  FlGridData getGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color(0xff37434d),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Color(0xff37434d),
          strokeWidth: 1,
        );
      },
    );
  }
}
