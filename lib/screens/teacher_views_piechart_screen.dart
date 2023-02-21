import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/teachers_views_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/date_filter_button.dart';
import 'package:my_school/shared/widgets/date_filter_title_widget.dart';
import 'package:my_school/shared/widgets/teacher_views_navigation_bar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:my_school/shared/widgets/pie_chart_widget.dart';

class TeacherViewsPiechartScreen extends StatefulWidget {
  const TeacherViewsPiechartScreen({Key key}) : super(key: key);

  @override
  State<TeacherViewsPiechartScreen> createState() =>
      _TeacherViewsPiechartScreenState();
}

class _TeacherViewsPiechartScreenState
    extends State<TeacherViewsPiechartScreen> {
  var lang = CacheHelper.getData(key: "lang");
  var teacherId = CacheHelper.getData(key: "teacherId");
  var token = CacheHelper.getData(key: "token");
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
  int maxCount;
  TeacherViewsModel model;
  dynamic maxWatchDuration = 1.0;
  dynamic maxAverageDuration = 1.0;
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
  Map<String, double> pieChartVideosAverageWatchDuration;
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

      GetChartData();
    });
  }

  void GetChartData() {
    model = null;
    DioHelper.getData(
            url: "Report_TeacherViews",
            query: {
              "TeacherId": teacherId,
              "FromDate": fromDate,
              "ToDate": toDate
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
        model = TeacherViewsModel.fromJson(value.data["data"]);
        pieChartVideosCount = model.subjectReports
                    .where((element) => element.videoWatched > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.subjectReports
                    .where((element) => element.videoWatched > 0),
                key: (e) => '${e.subjectName.toString()}_${e.yearOfStudy}',
                value: (e) => e.videoWatched.toDouble());
        pieChartVideosDurations = model.subjectReports
                    .where((element) => element.videoWatched > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.subjectReports
                    .where((element) => element.videoWatched > 0),
                key: (e) =>
                    '${e.subjectName.toString()}_${e.yearOfStudy} (${e.totalVideoDurationFormatted})',
                value: (e) => e.totalVideoDuration.toDouble());
        pieChartVideosAverageWatchDuration = model.subjectReports
                    .where((element) => element.videoWatched > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.subjectReports
                    .where((element) => element.videoWatched > 0),
                key: (e) =>
                    '${e.subjectName.toString()}_${e.yearOfStudy} (${e.averageWatchDurationFormatted})',
                value: (e) => e.averageWatchDuration.toDouble());
        pieChartQuizzesCount = model.subjectReports
                    .where((element) => element.totalQuizzes > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.subjectReports
                    .where((element) => element.totalQuizzes > 0),
                key: (e) => '${e.subjectName.toString()}_${e.yearOfStudy}',
                value: (e) => e.totalQuizzes.toDouble());
        pieChartQuizzesDegree = model.subjectReports
                    .where((element) => element.totalQuizzes > 0)
                    .length ==
                0
            ? null
            : Map.fromIterable(
                model.subjectReports
                    .where((element) => element.totalQuizzes > 0),
                key: (e) =>
                    '${e.subjectName.toString()}_${e.yearOfStudy} (${e.averageQuizzes.toDouble()} %)',
                value: (e) => e.averageQuizzes.toDouble());
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
          ? appBarComponent(context, "Views")
          : null,
      bottomNavigationBar:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? TeacherViewsNavigationBar(PageIndex: pageIndex.PieChart.index)
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
                                    : "عدد مشاهدة الفيديوهات",
                              ),
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
                                    ? "Average Watch Duration"
                                    : "متوسط زمن المشاهدة",
                              ),
                              PieChartWidget(
                                chartData: pieChartVideosAverageWatchDuration,
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
