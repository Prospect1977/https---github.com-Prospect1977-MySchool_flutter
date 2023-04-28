import 'package:flutter/material.dart';
import 'package:my_school/models/Teacher_Views_Overtime_model.dart';
import 'package:my_school/models/teacher_purchases_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class LineChartWidget extends StatelessWidget {
  final List<trafficItem> chartData;
  //final List<ExpenseLineData_split> chartData_split;
  //final bool splitByCategory;
  LineChartWidget(this.chartData);

  @override
  Widget build(BuildContext context) {
    var sourceDate = chartData;

    var lineSeriesArr = [];
    var line = LineSeries<trafficItem, String>(
        name: "all",
        dataSource: sourceDate,
        xValueMapper: (trafficItem exp, _) => exp.dataDate.toString(),
        yValueMapper: (trafficItem exp, _) => exp.traffics,
        // Enable data label
        dataLabelSettings: DataLabelSettings(isVisible: true));
    lineSeriesArr.add(line);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? 375
            : 250,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),

            // Chart title
            //title: ChartTitle(text: 'Half yearly sales analysis'),
            // Enable legend
            legend: Legend(
                isVisible: false,
                overflowMode: LegendItemOverflowMode.wrap,
                position:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? LegendPosition.bottom
                        : LegendPosition.right),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <LineSeries<trafficItem, String>>[...lineSeriesArr]),
      ),
    );
  }
}

class RevenueLineChartWidget extends StatelessWidget {
  final List<purchaseItem> chartData;
  //final List<ExpenseLineData_split> chartData_split;
  //final bool splitByCategory;
  RevenueLineChartWidget(this.chartData);

  @override
  Widget build(BuildContext context) {
    var sourceDate = chartData;

    var lineSeriesArr = [];
    var line = LineSeries<purchaseItem, String>(
        name: "all",
        dataSource: sourceDate,
        xValueMapper: (purchaseItem exp, _) => exp.dataDate.toString(),
        yValueMapper: (purchaseItem exp, _) => exp.totalAmount,
        // Enable data label
        dataLabelSettings: DataLabelSettings(isVisible: true));
    lineSeriesArr.add(line);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height - 300
            : MediaQuery.of(context).size.height - 50,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),

            // Chart title
            //title: ChartTitle(text: 'Half yearly sales analysis'),
            // Enable legend
            legend: Legend(
                isVisible: false,
                overflowMode: LegendItemOverflowMode.wrap,
                position:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? LegendPosition.bottom
                        : LegendPosition.right),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <LineSeries<purchaseItem, String>>[...lineSeriesArr]),
      ),
    );
  }
}
