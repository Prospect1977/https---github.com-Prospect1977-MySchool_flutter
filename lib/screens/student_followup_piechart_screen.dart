import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/student_progress_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/date_filter_button.dart';
import 'package:my_school/shared/widgets/date_filter_title_widget.dart';
import 'package:my_school/shared/widgets/pie_chart_widget.dart';
import 'package:my_school/shared/widgets/student_navigation_bar.dart';
import 'package:sorted/sorted.dart';

class StudentFollowupPiechartScreen extends StatefulWidget {
  final int StudentId;
  final String StudentName;
  const StudentFollowupPiechartScreen(
      {@required this.StudentId, @required this.StudentName, Key key})
      : super(key: key);

  @override
  State<StudentFollowupPiechartScreen> createState() =>
      _StudentFollowupPiechartScreenState();
}

class _StudentFollowupPiechartScreenState
    extends State<StudentFollowupPiechartScreen> {
  StudentProgressModel model;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
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
  Map<String, double> pieChartVideosCount;
  Map<String, double> pieChartVideosDurations;
  Map<String, double> pieChartQuizzesCount;
  Map<String, double> pieChartQuizzesDegree;

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
      GetChartData();
    });
  }

  void GetChartData() {
    model = null;
    DioHelper.getData(
            url: "ReportStudentProgress",
            query: {
              "StudentId": widget.StudentId,
              "WholeTerm": false,
              "fromDate": fromDate,
              "toDate": toDate,
              "DataDate": DateTime.now()
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      setState(() {
        print(value.data["data"]);
        model = StudentProgressModel.fromJson(value.data["data"]);
        // var SortedData = value.data["data"].sort(
        //     (a, b) => a.watchedVideosCount.compareTo(b.watchedVideosCount));
        // pieChartVideosCount = Map.fromIterable(
        //     StudentProgressModel.fromJson(SortedData).items.where((element) =>
        //         element.watchedVideosCount > 0 || element.quizzesDone > 0),
        //     key: (e) => e.subjectName.toString(),
        //     value: (e) => e.watchedVideosCount.toDouble());

        pieChartVideosCount = model.items
                    .where((element) => element.watchedVideosCount > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.items
                    // ..sort((a, b) =>
                    //     b.watchedVideosCount.compareTo(a.watchedVideosCount))
                    .where((element) => element.watchedVideosCount > 0),
                key: (e) => e.subjectName.toString(),
                value: (e) => e.watchedVideosCount.toDouble());
        pieChartVideosDurations = model.items
                    .where((element) => element.watchedVideosCount > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.items.where((element) => element.watchedVideosCount > 0),
                key: (e) => '${e.subjectName} (${e.watchedDurationFormatted})',
                value: (e) => e.watchedDuration.toDouble());
        pieChartQuizzesCount =
            model.items.where((element) => element.quizzesDone > 0).length == 0
                ? null
                : Map.fromIterable(
                    model.items.where((element) => element.quizzesDone > 0),
                    key: (e) => e.subjectName.toString(),
                    value: (e) => e.quizzesDone.toDouble());
        pieChartQuizzesDegree = model.items
                    .where((element) => element.quizzesDone > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.items.where((element) => element.quizzesDone > 0),
                key: (e) =>
                    '${e.subjectName.toString()} (${e.averageQuizzesDegree.toDouble()} %)',
                value: (e) => e.averageQuizzesDegree.toDouble());
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  void initState() {
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
    GetChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? appBarComponent(context, widget.StudentName)
          : null,
      body: RefreshIndicator(
          onRefresh: () async {
            GetChartData();
          },
          child: model == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            DateFilterButton(
                              caption: lang == "en" ? 'Yesterday' : "الأمس",
                              active: _filterBy == 'lastDay',
                              onClick: _onFilterButtonClick,
                              fromDate: today.subtract(Duration(days: 1)),
                              toDate: today.subtract(Duration(days: 1)),
                              filterBy: 'lastDay',
                            ),
                            DateFilterButton(
                              caption: lang == "en" ? 'Today' : "اليوم",
                              active: _filterBy == 'thisDay',
                              fromDate: today,
                              toDate: today,
                              onClick: _onFilterButtonClick,
                              filterBy: 'thisDay',
                            ),
                            DateFilterButton(
                              caption:
                                  lang == "en" ? 'This Week' : "هذا الأسبوع",
                              active: _filterBy == 'thisWeek',
                              onClick: _onFilterButtonClick,
                              fromDate: date_thisWeekFirstDay,
                              toDate: today,
                              filterBy: 'thisWeek',
                            ),
                            DateFilterButton(
                              caption:
                                  lang == "en" ? 'Last Week' : "الأسبوع الماضي",
                              active: _filterBy == 'lastWeek',
                              onClick: _onFilterButtonClick,
                              fromDate: date_lastWeekFirstDay,
                              toDate: date_lastWeekLastDay,
                              filterBy: 'lastWeek',
                            ),
                            DateFilterButton(
                              caption:
                                  lang == "en" ? 'This Month' : "هذا الشهر",
                              active: _filterBy == 'thisMonth',
                              onClick: _onFilterButtonClick,
                              fromDate: date_firstDateOfThisMonth,
                              toDate: today,
                              filterBy: 'thisMonth',
                            ),
                            DateFilterButton(
                              caption:
                                  lang == "en" ? 'Last Month' : "الشهر الماضي",
                              active: _filterBy == 'lastMonth',
                              onClick: _onFilterButtonClick,
                              fromDate: date_firstDateOfLastMonth,
                              toDate: date_lastDateOfLastMonth,
                              filterBy: 'lastMonth',
                            ),
                            DateFilterButton(
                              caption: lang == "en" ? 'This Year' : "هذا العام",
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
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? Container()
                                  : DateFilterTitleWidget(
                                      title: lang == "en"
                                          ? 'From ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} TO ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}'
                                          : 'من ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} إلى ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}',
                                    ),
                              ChartTitle(
                                  title: lang == "en"
                                      ? "Watched Videos"
                                      : "عدد مشاهدة الفيديوهات"),
                              PieChartWidget(
                                chartData: pieChartVideosCount,
                                showPercentage: false,
                              ),
                              ChartTitle(
                                title: lang == "en"
                                    ? "Total Watch Duration"
                                    : "إجمالي زمن المشاهدة ",
                              ),
                              PieChartWidget(
                                chartData: pieChartVideosDurations,
                                showPercentage: true,
                              ),
                              ChartTitle(
                                title: lang == "en"
                                    ? "Quizzes Done"
                                    : "عدد الإختبارات المُنجزة ",
                              ),
                              PieChartWidget(
                                chartData: pieChartQuizzesCount,
                                showPercentage: false,
                              ),
                              ChartTitle(
                                title: lang == "en"
                                    ? "Quizzes Average Score"
                                    : "متوسط درجات الاختبارات",
                              ),
                              PieChartWidget(
                                chartData: pieChartQuizzesDegree,
                                showPercentage: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      bottomNavigationBar:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? StudentNavigationBar(
                  PageIndex: pageIndex.PieChart.index,
                  StudentId: widget.StudentId,
                  StudentName: widget.StudentName,
                )
              : null,
    );
  }
}

class ChartTitle extends StatelessWidget {
  const ChartTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: defaultColor.withOpacity(0.05),
            border: Border(
                top: BorderSide(color: defaultColor.withOpacity(0.25)),
                bottom: BorderSide(color: defaultColor.withOpacity(0.25)))),
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            title,
            style:
                TextStyle(fontSize: 20, color: defaultColor.withOpacity(0.8)),
          ),
        ));
  }
}
