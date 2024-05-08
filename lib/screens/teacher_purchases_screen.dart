import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/teacher_purchases_model.dart';
import 'package:my_school/models/teachers_views_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/screens/teacher_session_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/date_filter_button.dart';
import 'package:my_school/shared/widgets/date_filter_title_widget.dart';
import 'package:my_school/shared/widgets/teacher_purchases_navigation_bar.dart';
import 'package:my_school/shared/widgets/teacher_views_navigation_bar.dart';
import 'package:intl/intl.dart' as intl;

class TeacherPurchasesScreen extends StatefulWidget {
  const TeacherPurchasesScreen({Key key}) : super(key: key);

  @override
  State<TeacherPurchasesScreen> createState() => _TeacherPurchasesScreenState();
}

class _TeacherPurchasesScreenState extends State<TeacherPurchasesScreen> {
  var lang = CacheHelper.getData(key: "lang");
  var teacherId = CacheHelper.getData(key: "teacherId");
  var token = CacheHelper.getData(key: "token");
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
  int maxCount;
  TeacherPurchases model;
  dynamic maxPurchasesCount = 1;
  dynamic maxPurchasesAmount = 1.0;
  dynamic netMaxPurchasesAmount = 1.0;
  DateTime fromDate = DateTime.now();
  TeacherPurchasesTotals modelTotal;
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
      GetData();
    });
  }

  void GetData() {
    model = null;
    DioHelper.getData(
            url: "Report_Teacher_Purchases_",
            query: {
              "TeacherId": teacherId,
              "FromDate": fromDate,
              "ToDate": toDate
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        print(value.data["data"]);
        model = TeacherPurchases.fromJson(value.data["data"]);
        modelTotal =
            TeacherPurchasesTotals.fromJson(value.data["additionalData"]);
        maxPurchasesAmount = [...model.Records].fold<dynamic>(
            1, (max, e) => e.totalAmount > max ? e.totalAmount : max);
        maxPurchasesAmount = [...model.Records].fold<dynamic>(
            1, (max, e) => e.totalAmount > max ? e.totalAmount : max);
        netMaxPurchasesAmount = [...model.Records]
            .fold<dynamic>(
                1, (max, e) => e.netTotalAmount > max ? e.netTotalAmount : max)
            .toStringAsFixed(2);

        print(
            'maxPurchasesCount=-----------------------------------$maxPurchasesCount');
        print(
            'maxPurchasesAmount=-----------------------------------$maxPurchasesAmount');

        //print(maxCount);
      });
    }).catchError((e) {
      showToast(text: e.toString(), state: ToastStates.ERROR);
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
    GetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, "Views"),
      bottomNavigationBar: TeacherPurchasesNavigationBar(PageIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          GetData();
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
                                        ? "Total Transactions:"
                                        : "إجمالي عدد العمليات:",
                                    value: modelTotal.totalPurchasesCount
                                        .toString()),
                                Divider(
                                    height: 0,
                                    thickness: 0.1,
                                    color: defaultColor.withOpacity(0.2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Total Revenue:"
                                        : "إجمالي الدخل:",
                                    value: modelTotal.totalPurchasesAmount
                                        .toStringAsFixed(2)),
                                SummaryRow(
                                    label: lang == "en"
                                        ? "Net Revenue:"
                                        : "صافي الدخل:",
                                    value: modelTotal.netTotalPurchasesAmount
                                        .toStringAsFixed(2)),
                                Divider(
                                    height: 0,
                                    thickness: 1,
                                    color: defaultColor.withOpacity(0.2)),
                              ]),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8),
                              child: modelTotal.totalPurchasesCount == 0
                                  ? Container()
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: model.Records.length,
                                      itemBuilder: (context, index) {
                                        var item = model.Records[index];
                                        return BuildItem(
                                          item: item,
                                          lang: lang,
                                          MaxCount: maxPurchasesCount,
                                          maxAmount: maxPurchasesAmount,
                                          TeacherId: teacherId,
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
      height: 40,
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
    @required this.maxAmount,
    @required this.TeacherId,
  }) : super(key: key);

  final Record item;
  final String lang;
  final dynamic maxAmount;
  final int MaxCount;
  final int TeacherId;
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
          height: 35,
          width: double.infinity,
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_sharp,
                size: 20,
                color: defaultColor,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                formatDate(DateTime.parse(item.dataDate), lang),
                style: TextStyle(
                    color: defaultColor.withOpacity(0.8),
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              border: Border(
                  bottom: BorderSide(color: defaultColor.withOpacity(0.35)))),
        ),
        item.items.length <= 1
            ? Container()
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
                          widthFactor: item.totalPurchases / MaxCount,
                          caption: lang == "en"
                              ? "Transactions:"
                              : "إجمالي العمليات:",
                          value: item.totalPurchases.toString(),
                        ),
                        Divider(),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.totalAmount / maxAmount,
                          caption:
                              lang == "en" ? "Total Revenue:" : "إجمالي الدخل:",
                          value: item.totalAmount.toStringAsFixed(2),
                        ),
                        DataRow(
                          lang: lang,
                          item: item,
                          widthFactor: item.totalAmount / maxAmount,
                          caption: lang == "en"
                              ? "Net Total Revenue:"
                              : "صافي إجمالي الدخل:",
                          value: item.netTotalAmount.toStringAsFixed(2),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.black45,
                        ),
                      ]),
                ),
              ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: item.items.length,
            itemBuilder: ((context, index) {
              var rec = item.items[index];
              return Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    SizedBox(
                      height: 5,
                    ),
                    Directionality(
                        textDirection: rec.dir == "ltr"
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: InkWell(
                          onTap: () {
                            navigateTo(
                                context,
                                TeacherSessionScreen(
                                  LessonId: rec.lessonId,
                                  LessonName: rec.lessonName,
                                  dir: rec.dir,
                                  TermIndex: rec.termIndex,
                                  YearSubjectId: rec.yearSubjectId,
                                  TeacherId: TeacherId,
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.06),
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.2)))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    rec.lessonName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color:
                                            Colors.deepPurple.withOpacity(0.8)),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${rec.subjectName} - ${rec.yearOfStudy}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Colors.deepPurple.withOpacity(0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: lang == "en" ? 107 : 85,
                            alignment: lang == "en"
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              '${lang == "en" ? "Transactions:" : "عدد العمليات:"}',
                              style:
                                  TextStyle(fontSize: 16, color: defaultColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text('${rec.count}',
                                style: TextStyle(
                                    fontSize: 16, color: defaultColor)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: lang == "en" ? 107 : 85,
                            alignment: lang == "en"
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              '${lang == "en" ? "Revenue:" : "الدخل:"}',
                              style:
                                  TextStyle(fontSize: 16, color: defaultColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text('${rec.amount}',
                                style: TextStyle(
                                    fontSize: 16, color: defaultColor)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: lang == "en" ? 107 : 85,
                            alignment: lang == "en"
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              '${lang == "en" ? "Net Revenue:" : "صافي الدخل:"}',
                              style:
                                  TextStyle(fontSize: 16, color: defaultColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text('${rec.netAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 16, color: defaultColor)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ]));
            }),
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
      @required this.caption,
      @required this.value,
      @required this.widthFactor})
      : super(key: key);

  final String lang;
  final Record item;
  final String caption;
  final String value;
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
