import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/styles/colors.dart';
import '../shared/widgets/date_filter_button.dart';

class AdminRecentParentsScreen extends StatefulWidget {
  const AdminRecentParentsScreen({Key key}) : super(key: key);

  @override
  State<AdminRecentParentsScreen> createState() =>
      _AdminRecentParentsScreenState();
}

class _AdminRecentParentsScreenState extends State<AdminRecentParentsScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime today = new DateTime.now();
  DateTime date_thisWeekFirstDay;
  DateTime date_lastWeekFirstDay;
  DateTime date_lastWeekLastDay;
  DateTime date_firstDateOfThisMonth;
  DateTime date_firstDateOfLastMonth;
  DateTime date_lastDateOfLastMonth;
  DateTime date_firstDateOfThisYear;

  int lastMonth;
  int lastMonthYear;

  String _filterBy = "thisDay";
  void _onFilterButtonClick(DateTime FromDate, DateTime ToDate, String Filter) {
    setState(() {
      fromDate = FromDate;
      toDate = ToDate;
      _filterBy = Filter;
      date_thisWeekFirstDay =
          today.subtract(Duration(days: weekDaySundayBased(today.weekday)));
      date_lastWeekFirstDay = date_thisWeekFirstDay.subtract(Duration(days: 7));
      date_lastWeekLastDay = date_lastWeekFirstDay.add(Duration(days: 6));
      date_firstDateOfThisMonth = DateTime(today.year, today.month, 1);
      date_firstDateOfThisYear = DateTime(today.year, 1, 1);
      lastMonth = today.month == 1 ? 12 : today.month - 1;
      lastMonthYear = today.month == 1 ? today.year - 1 : today.year;
      date_firstDateOfLastMonth = DateTime(lastMonthYear, lastMonth, 1);
      date_lastDateOfLastMonth = date_firstDateOfLastMonth.add(Duration(
          days: getMonthDays(date_firstDateOfLastMonth.month, lastMonthYear) -
              1));
      print(
          'fromDate:-------------------------------------${fromDate.weekday}');
      print('toDate:---------------------------------------$toDate');
      getData();
    });
  }

  Future<void> getData() async {}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date_thisWeekFirstDay =
        today.subtract(Duration(days: weekDaySundayBased(today.weekday)));
    date_lastWeekFirstDay = date_thisWeekFirstDay.subtract(Duration(days: 7));
    date_lastWeekLastDay = date_lastWeekFirstDay.add(Duration(days: 6));
    date_firstDateOfThisMonth = DateTime(today.year, today.month, 1);
    date_firstDateOfThisYear = DateTime(today.year, 1, 1);
    lastMonth = today.month == 1 ? 12 : today.month - 1;
    lastMonthYear = today.month == 1 ? today.year - 1 : today.year;
    date_firstDateOfLastMonth = DateTime(lastMonthYear, lastMonth, 1);
    date_lastDateOfLastMonth = date_firstDateOfLastMonth.add(Duration(
        days:
            getMonthDays(date_firstDateOfLastMonth.month, lastMonthYear) - 1));
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, "أولياء الأمور والطلبة"),
        body: Column(children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                DateFilterButton(
                  caption: "الأمس",
                  active: _filterBy == 'lastDay',
                  onClick: _onFilterButtonClick,
                  fromDate: today.subtract(Duration(days: 1)),
                  toDate: today.subtract(Duration(days: 1)),
                  filterBy: 'lastDay',
                ),
                DateFilterButton(
                  caption: "اليوم",
                  active: _filterBy == 'thisDay',
                  fromDate: today,
                  toDate: today,
                  onClick: _onFilterButtonClick,
                  filterBy: 'thisDay',
                ),
                DateFilterButton(
                  caption: "هذا الأسبوع",
                  active: _filterBy == 'thisWeek',
                  onClick: _onFilterButtonClick,
                  fromDate: date_thisWeekFirstDay,
                  toDate: today,
                  filterBy: 'thisWeek',
                ),
                DateFilterButton(
                  caption: "الأسبوع الماضي",
                  active: _filterBy == 'lastWeek',
                  onClick: _onFilterButtonClick,
                  fromDate: date_lastWeekFirstDay,
                  toDate: date_lastWeekLastDay,
                  filterBy: 'lastWeek',
                ),
                DateFilterButton(
                  caption: "هذا الشهر",
                  active: _filterBy == 'thisMonth',
                  onClick: _onFilterButtonClick,
                  fromDate: date_firstDateOfThisMonth,
                  toDate: today,
                  filterBy: 'thisMonth',
                ),
                DateFilterButton(
                  caption: "الشهر الماضي",
                  active: _filterBy == 'lastMonth',
                  onClick: _onFilterButtonClick,
                  fromDate: date_firstDateOfLastMonth,
                  toDate: date_lastDateOfLastMonth,
                  filterBy: 'lastMonth',
                ),
                DateFilterButton(
                  caption: "هذا العام",
                  active: _filterBy == 'thisYear',
                  onClick: _onFilterButtonClick,
                  fromDate: DateTime(today.year, 1, 1),
                  toDate: today,
                  filterBy: 'thisYear',
                ),
              ])),
          Divider(
            height: 3,
            color: defaultColor.withOpacity(0.2),
            thickness: 1,
          ),
          Expanded(
            child: Container(),
          )
        ]));
  }
}
