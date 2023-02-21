import 'package:flutter/material.dart';
import 'package:my_school/shared/cache_helper.dart';

import 'package:pie_chart/pie_chart.dart' as pchart;

class PieChartWidget extends StatelessWidget {
  PieChartWidget({@required this.chartData, @required this.showPercentage});
  final chartData;
  final showPercentage;
  var lang = CacheHelper.getData(key: "lang");
  @override
  Widget build(BuildContext context) {
    return chartData == null
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 50,
            child: Center(
              child: Text(
                lang == "en" ? "No data found!" : "لا توجد بيانات!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontStyle: FontStyle.italic),
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.red.withAlpha(50),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(5)),
          )
        : pchart.PieChart(
            dataMap: chartData,
            chartValuesOptions: pchart.ChartValuesOptions(
                showChartValues: true,
                showChartValuesInPercentage: showPercentage),
            legendOptions: pchart.LegendOptions(
              showLegendsInRow: false,
              legendPosition:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? pchart.LegendPosition.bottom
                      : pchart.LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            colorList: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.indigo,
              Color.fromARGB(255, 238, 255, 7),
              Color.fromRGBO(255, 160, 132, 1),
              Colors.black45,
              Color.fromARGB(255, 244, 54, 212),
              Color.fromARGB(255, 76, 168, 175),
              Color.fromARGB(255, 155, 176, 39),
              Color.fromARGB(255, 167, 118, 28),
              Colors.indigo,
              Color.fromARGB(255, 255, 215, 203),
              Color.fromARGB(255, 0, 102, 60),
              Color.fromARGB(255, 238, 255, 7),
              Colors.black38,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.indigo,
              Color.fromARGB(255, 238, 255, 7),
              Color.fromRGBO(255, 160, 132, 1),
              Colors.black45,
              Color.fromARGB(255, 244, 54, 212),
              Color.fromARGB(255, 76, 168, 175),
              Color.fromARGB(255, 155, 176, 39),
              Color.fromARGB(255, 167, 118, 28),
              Colors.indigo,
              Color.fromARGB(255, 255, 215, 203),
              Color.fromARGB(255, 0, 102, 60),
              Color.fromARGB(255, 238, 255, 7),
              Colors.black38,
            ],
            chartRadius:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 325
                    : 250,
          );
  }
}
