import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/student_progress_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/date_filter_button.dart';
import 'package:my_school/shared/widgets/date_filter_title_widget.dart';
import 'package:my_school/shared/widgets/student_navigation_bar.dart';

class StudentFollowupListScreen extends StatefulWidget {
  final int StudentId;
  final String StudentName;

  StudentFollowupListScreen(
      {@required this.StudentId, @required this.StudentName, Key key})
      : super(key: key);

  @override
  State<StudentFollowupListScreen> createState() =>
      _StudentFollowupListScreenState();
}

class _StudentFollowupListScreenState extends State<StudentFollowupListScreen> {
  StudentProgressModel model;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  dynamic maxProgressVideos = 0.0;
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
  int MaxCount = 0;
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
            url: "ReportStudentProgress",
            query: {
              "StudentId": widget.StudentId,
              "WholeTerm": false,
              "DataDate": DateTime.now(),
              "fromDate": fromDate,
              "toDate": toDate,
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
        maxProgressVideos = [...model.items].fold<dynamic>(
            0, (max, e) => e.watchedDuration > max ? e.watchedDuration : max);

        var maxVidCount = [...model.items].fold<dynamic>(
            0,
            (max, e) =>
                e.watchedVideosCount > max ? e.watchedVideosCount : max);
        var maxQzCount = [...model.items].fold<dynamic>(
            0, (max, e) => e.quizzesDone > max ? e.quizzesDone : max);
        MaxCount = maxVidCount >= maxQzCount ? maxVidCount : maxQzCount;
        print(maxProgressVideos);
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void _checkAppVersion() async {
    await checkAppVersion();
    bool isUpdated = CacheHelper.getData(key: "isLatestVersion");
    if (isUpdated == false) {
      navigateTo(context, RequireUpdateScreen());
    }
  }

  @override
  void initState() {
    super.initState();

    _checkAppVersion();

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
    return RefreshIndicator(
      onRefresh: () async {
        GetChartData();
      },
      child: Scaffold(
          appBar: MediaQuery.of(context).orientation == Orientation.portrait
              ? appBarComponent(context, widget.StudentName)
              : null,
          body: model == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: lang == "en"
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: SingleChildScrollView(
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
                                caption: lang == "en"
                                    ? 'Last Week'
                                    : "الأسبوع الماضي",
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
                                caption: lang == "en"
                                    ? 'Last Month'
                                    : "الشهر الماضي",
                                active: _filterBy == 'lastMonth',
                                onClick: _onFilterButtonClick,
                                fromDate: date_firstDateOfLastMonth,
                                toDate: date_lastDateOfLastMonth,
                                filterBy: 'lastMonth',
                              ),
                              DateFilterButton(
                                caption:
                                    lang == "en" ? 'This Year' : "هذا العام",
                                active: _filterBy == 'thisYear',
                                onClick: _onFilterButtonClick,
                                fromDate: DateTime(today.year, 1, 1),
                                toDate: today,
                                filterBy: 'thisYear',
                              ),
                            ])),
                      ),
                      Divider(
                        height: 3,
                        color: defaultColor.withOpacity(0.2),
                        thickness: 1,
                      ),
                      MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? Container()
                          : DateFilterTitleWidget(
                              title: lang == "en"
                                  ? 'From ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} TO ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}'
                                  : 'من ${getDayName(fromDate.weekday, lang)} ${fromDate.day} ${getMonthName(fromDate.month, lang)} ${fromDate.year} إلى ${getDayName(toDate.weekday, lang)} ${toDate.day} ${getMonthName(toDate.month, lang)} ${toDate.year}',
                            ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: model.items.length,
                          itemBuilder: (context, index) {
                            var item = model.items[index];
                            return BuildItem(
                              item: item,
                              lang: lang,
                              MaxCount: MaxCount,
                              maxProgressVideos: maxProgressVideos,
                            );
                          },
                        ),
                      )),
                      MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? Container()
                          : StudentNavigationBar(
                              PageIndex: pageIndex.List.index,
                              StudentId: widget.StudentId,
                              StudentName: widget.StudentName,
                            )
                    ],
                  ),
                )),
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
  }) : super(key: key);

  final StudentProgressRecord item;
  final String lang;
  final dynamic maxProgressVideos;

  final int MaxCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border.all(color: defaultColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(children: [
        Container(
          height: 32,
          width: double.infinity,
          padding: EdgeInsets.all(4),
          child: Center(
            child: Text(
              item.subjectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: interfaceColor.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: defaultColor.withOpacity(0.2))),
            color: Colors.black.withOpacity(0.02),
          ),
        ),
        item.quizzesDone == 0 && item.watchedVideosCount == 0
            ? Container(
                height: 151,
                color: Colors.black.withOpacity(0.005),
                child: Center(
                  child: Text(
                    lang == "en"
                        ? "No Activities found so far!"
                        : "لا يوجد نشاط مسجل حتى الآن!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.25),
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
                          MaxCount: MaxCount,
                          widthFactor: MaxCount == 0
                              ? 0.0
                              : item.watchedVideosCount / MaxCount,
                          caption: lang == "en"
                              ? "Watched Videos:"
                              : "عدد المشاهدات:",
                          value: item.watchedVideosCount.toString(),
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          MaxCount: MaxCount,
                          widthFactor: maxProgressVideos == 0
                              ? 0.0
                              : item.watchedDuration / maxProgressVideos,
                          caption: lang == "en"
                              ? "Total watched duration:"
                              : "إجمالي زمن المشاهدات:",
                          value: item.watchedDurationFormatted,
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          MaxCount: MaxCount,
                          widthFactor:
                              MaxCount == 0 ? 0.0 : item.quizzesDone / MaxCount,
                          caption: lang == "en"
                              ? "Quizzes Count:"
                              : "عدد الاختبارات:",
                          value: item.quizzesDone.toString(),
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          MaxCount: MaxCount,
                          widthFactor: item.averageQuizzesDegree / 100,
                          caption: lang == "en"
                              ? "Average Degree:"
                              : "متوسط الدرجات:",
                          value:
                              '${item.averageQuizzesDegree.toStringAsFixed(1)}%',
                        ),
                      ]),
                ),
              )
      ]),
    );
  }
}

class DataRow extends StatelessWidget {
  DataRow(
      {Key key,
      @required this.lang,
      @required this.item,
      @required this.MaxCount,
      @required this.caption,
      @required this.value,
      @required this.widthFactor})
      : super(key: key);

  final String lang;
  final StudentProgressRecord item;
  final String caption;
  final String value;
  final int MaxCount;
  dynamic widthFactor = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            width: 125,
            child: Text(caption),
          ),
          Expanded(
            child: Container(
                alignment:
                    lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
                height: 4,
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
            child: FittedBox(child: Text(value)),
          ),
        ],
      ),
    );
  }
}
