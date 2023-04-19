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

class TeacherViewsScreen extends StatefulWidget {
  const TeacherViewsScreen({Key key}) : super(key: key);

  @override
  State<TeacherViewsScreen> createState() => _TeacherViewsScreenState();
}

class _TeacherViewsScreenState extends State<TeacherViewsScreen> {
  var lang = CacheHelper.getData(key: "lang");
  var teacherId = CacheHelper.getData(key: "teacherId");
  var token = CacheHelper.getData(key: "token");
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
  int maxCount;
  TeacherViewsModel model;
  dynamic maxWatchDuration = 1.0;
  dynamic maxAverageDuration = 1.0;
  DateTime fromDate = DateTime.now();
  // of to be removed
  //DateTime fromDate = DateTime.now().subtract(Duration(days: 365));
  //End of to be removed
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
        var maxViews = [...model.subjectReports].fold<dynamic>(
            1, (max, e) => e.videoWatched > max ? e.videoWatched : max);

        maxWatchDuration = [...model.subjectReports].fold<dynamic>(
            1,
            (max, e) =>
                e.totalVideoDuration > max ? e.totalVideoDuration : max);
        maxAverageDuration = [...model.subjectReports].fold<dynamic>(
            1,
            (max, e) =>
                e.averageWatchDuration > max ? e.averageWatchDuration : max);
        print(
            'maxAverageDuration=-----------------------------------$maxAverageDuration');

        var maxQzCount = [...model.subjectReports].fold<dynamic>(
            1, (max, e) => e.totalQuizzes > max ? e.totalQuizzes : max);
        maxCount = maxViews >= maxQzCount ? maxViews : maxQzCount;
        print(maxCount);
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
      appBar: appBarComponent(context, "Views"),
      bottomNavigationBar:
          TeacherViewsNavigationBar(PageIndex: pageIndex.Views.index),
      body: RefreshIndicator(
        onRefresh: () async {
          GetChartData();
        },
        child: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Directionality(
                textDirection:
                    lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      DateFilterTitleWidget(
                        title: lang == "en"
                            ? 'From ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} TO ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}'
                            : 'من ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} إلى ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}',
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            Container(
                              child: Column(children: [
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Total Video Views:"
                                        : "إجمالي عدد المشاهدات:",
                                    value: model.totalVideosWatches.toString()),
                                Divider(
                                    height: 0,
                                    thickness: 0.1,
                                    color: defaultColor.withOpacity(0.2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Total Views Duration:"
                                        : "إجمالي زمن المشاهدات:",
                                    value: model.totalVideosDurationsFormatted
                                        .toString()),
                                Divider(
                                    height: 0,
                                    thickness: 0.1,
                                    color: defaultColor.withOpacity(0.2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Average View Duration:"
                                        : "متوسط زمن المشاهدة:",
                                    value: model.averageWatchDurationFormatted
                                        .toString()),
                                Divider(
                                    height: 0,
                                    thickness: 0.1,
                                    color: defaultColor.withOpacity(0.2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Total Answered Quizzes:"
                                        : "إجمالي عدد الإختبارات",
                                    value: model.totalQuizzes.toString()),
                                Divider(
                                    height: 0,
                                    thickness: 0.1,
                                    color: defaultColor.withOpacity(0.2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Average Quiz Result:"
                                        : "متوسط نتيجة الإختبار:",
                                    value: model.averageQuizzes.toString()),
                                Divider(
                                    height: 0,
                                    thickness: 1,
                                    color: defaultColor.withOpacity(0.2)),
                              ]),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8),
                              child: model.totalVideosWatches == 0 &&
                                      model.totalQuizzes == 0
                                  ? Container()
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: model.subjectReports.length,
                                      itemBuilder: (context, index) {
                                        var item = model.subjectReports[index];
                                        return BuildItem(
                                          item: item,
                                          lang: lang,
                                          MaxCount: maxCount,
                                          maxProgressVideos: maxWatchDuration,
                                          maxAverageWatchDuration:
                                              maxAverageDuration,
                                        );
                                      },
                                    ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    Key key,
    @required this.value,
    @required this.label,
  }) : super(key: key);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
          color: defaultColor.withOpacity(0.035),
          border: Border(
            top: BorderSide(color: defaultColor.withOpacity(0.2)),
          )),
      child: Row(
        children: [
          Container(
              width: 250,
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 16, color: defaultColor.withOpacity(0.75)),
              )),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 16,
                    color: defaultColor.withOpacity(0.75),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  const BuildItem({
    Key key,
    @required this.item,
    @required this.lang,
    @required this.MaxCount,
    @required this.maxProgressVideos,
    @required this.maxAverageWatchDuration,
  }) : super(key: key);

  final SubjectReport item;
  final String lang;
  final dynamic maxProgressVideos;

  final int MaxCount;
  final dynamic maxAverageWatchDuration;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: defaultColor.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(children: [
        Container(
          height: 30,
          width: double.infinity,
          padding: EdgeInsets.all(4),
          child: Text(
            item.subjectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: defaultColor.withOpacity(0.8),
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.02),
              border: Border(
                  bottom: BorderSide(color: defaultColor.withOpacity(0.35)))),
        ),
        item.totalQuizzes == 0 && item.videoWatched == 0
            ? Container(
                height: 197,
                color: Colors.black.withOpacity(0.03),
                child: Center(
                  child: Text(
                    lang == "en"
                        ? "No Activities found so far"
                        : "لا يوجد نشاط مسجل حتى الآن",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black38,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(8),
                child: Directionality(
                  textDirection:
                      lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.videoWatched / MaxCount,
                          caption:
                              lang == "en" ? "Views Count:" : "عدد المشاهدات:",
                          value: item.videoWatched.toString(),
                          MaxCount: MaxCount,
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor:
                              item.totalVideoDuration / maxProgressVideos,
                          caption: lang == "en"
                              ? "Total watched duration:"
                              : "إجمالي زمن المشاهدات:",
                          value: item.totalVideoDurationFormatted,
                          MaxCount: MaxCount,
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.averageWatchDuration /
                              maxAverageWatchDuration,
                          caption: lang == "en"
                              ? "Average watch duration:"
                              : "متوسط زمن المشاهدة:",
                          value: item.averageWatchDurationFormatted,
                          MaxCount: MaxCount,
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.totalQuizzes / MaxCount,
                          caption: lang == "en"
                              ? "Quizzes Count:"
                              : "عدد الاختبارات:",
                          value: item.totalQuizzes.toString(),
                          MaxCount: MaxCount,
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.averageQuizzes / 100,
                          caption: lang == "en"
                              ? "Average Degree:"
                              : "متوسط الدرجات:",
                          value: '${item.averageQuizzes.toStringAsFixed(1)}%',
                          MaxCount: MaxCount,
                        ),
                      ]),
                ),
              )
      ]),
    );
  }
}

class DataRow extends StatelessWidget {
  const DataRow(
      {Key key,
      @required this.lang,
      @required this.item,
      @required this.MaxCount,
      @required this.caption,
      @required this.value,
      @required this.widthFactor})
      : super(key: key);

  final String lang;
  final SubjectReport item;
  final String caption;
  final String value;
  final int MaxCount;
  final dynamic widthFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            width: 125,
            child: Text(
              caption,
              style: TextStyle(color: defaultColor.withOpacity(0.85)),
            ),
          ),
          Expanded(
            child: Container(
                alignment:
                    lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
                height: 3,
                width: double.infinity,
                child: Stack(children: [
                  FractionallySizedBox(
                    widthFactor: widthFactor,
                    heightFactor: 1,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.green),
                    ),
                  ),
                  Container(
                    color: Colors.black12,
                  )
                ])),
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            alignment:
                lang == "en" ? Alignment.centerRight : Alignment.centerLeft,
            width: 60,
            child: FittedBox(
              child: Text(
                value,
                style: TextStyle(color: defaultColor.withOpacity(0.85)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
