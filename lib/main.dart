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
  List<Color> gradientColors;
  double currentValue;

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
    gradientColors = [Theme.of(context).accentColor];
    var dataStream =
        timedCounter(Duration(milliseconds: 500)).asBroadcastStream();
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: StreamBuilder(
              stream: dataStream,
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                var stringAsFixed = snapshot.data.toStringAsFixed(2);
                if (stringAsFixed.length == 4) {
                  stringAsFixed = '0' + stringAsFixed;
                }
                return Text(
                  "pH: " + stringAsFixed.padLeft(1),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            isReading = !isReading;
          },
          child: isReading ? Icon(Icons.stop) : Icon(Icons.play_arrow)),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: StreamBuilder(
                      stream: dataStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        int max = 100;
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
                        return LineChart(mainData(context));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData(BuildContext context) {
    return LineChartData(
        gridData: getGridData(context),
        titlesData: getTitlesData(context),
        borderData: getBorderData(context),
        minX: 0,
        maxX: 101,
        minY: 0,
        maxY: 15,
        lineBarsData: getLineBarsData(),
        lineTouchData: getLineTouchData(context),
        backgroundColor: Theme.of(context).backgroundColor);
  }

  LineTouchData getLineTouchData(BuildContext context) {
    return LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).backgroundColor));
  }

  List<LineChartBarData> getLineBarsData() {
    return [
      LineChartBarData(
        spots: data,
        isCurved: true,
        colors: gradientColors,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
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

  FlBorderData getBorderData(BuildContext context) {
    return FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).backgroundColor, width: 1));
  }

  FlTitlesData getTitlesData(BuildContext context) {
    return FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        textStyle: Theme.of(context).primaryTextTheme.subtitle,
        getTitles: (value) {
          return '';
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        textStyle: Theme.of(context).textTheme.subtitle,
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

  FlGridData getGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Theme.of(context).primaryColor,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Theme.of(context).primaryColor,
          strokeWidth: 1,
        );
      },
    );
  }
}
