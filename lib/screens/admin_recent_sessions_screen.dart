import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:my_school/screens/teacher_session_screen.dart';

import '../shared/cache_helper.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';
import '../shared/styles/colors.dart';
import '../shared/widgets/date_filter_button.dart';

class AdminRecentSessionsScreen extends StatefulWidget {
  const AdminRecentSessionsScreen({Key key}) : super(key: key);

  @override
  State<AdminRecentSessionsScreen> createState() =>
      _AdminRecentSessionsScreenState();
}

class _AdminRecentSessionsScreenState extends State<AdminRecentSessionsScreen> {
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
      print('fromDate:-------------------------------------${fromDate}');
      print('toDate:---------------------------------------$toDate');
      getData();
    });
  }

  List<RecentSession> model;
  Future<void> getData() async {
    await DioHelper.getData(
        url: 'Admin/RecentSessions',
        query: {'StartDate': fromDate, 'EndDate': toDate}).then((value) {
      if (value.data['status'] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => RecentSession.fromJson(item))
            .toList();
      });
    }).catchError((ex) {
      showToast(text: ex.toString(), state: ToastStates.ERROR);
    });
  }

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
        appBar: appBarComponent(context, "الدروس"),
        body: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(children: [
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: model.length,
                      itemBuilder: (context, index) {
                        var item = model[index];
                        return SessionWidget(item);
                      },
                    ),
                  ),
                )
              ]));
  }
}

class SessionWidget extends StatelessWidget {
  SessionWidget(this.t, {Key key}) : super(key: key);
  RecentSession t;
  @override
  Widget build(BuildContext context) {
    var dataDate = DateTime.parse(t.sessionDate);
    return InkWell(
      onTap: () {
        CacheHelper.saveData(key: "teacherId", value: t.teacherId);
        CacheHelper.saveData(key: "fullName", value: t.teacherName);

        navigateTo(
            context,
            TeacherSessionScreen(
              LessonId: t.lessonId,
              LessonName: t.lessonName,
              TeacherId: t.teacherId,
              TermIndex: t.termIndex,
              YearSubjectId: t.yearSubjectId,
              dir: t.dir,
            ));
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CircleAvatar(
                  radius: 35,
                  child: t.teacherPhoto == null
                      ? Image.asset(
                          'assets/images/Teacher.jpg',
                        )
                      : Image.network(t.teacherPhotoUrlSource == "api"
                          ? '${baseUrl0}assets/ProfileImages/${t.teacherPhoto}'
                          : '${webUrl}images/Profiles/${t.teacherPhoto}'),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.teacherName),
                  Text(
                      '${getDayName(dataDate.weekday, "ar")} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}'),
                  Text(
                      '${t.subject} - ${t.yearOfStudy} - الترم ${t.termIndex}'),
                  Text(
                      '${t.lessonName} (${t.price == 0 ? "مجاني" : t.price.toString() + "ج.م"})'),
                ],
              )),
              IconButton(
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(t.phoneNumber);
                  },
                  icon: Image.asset(
                    'assets/images/phone.png',
                    width: 35,
                    height: 35,
                  ),
                  iconSize: 45),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentSession {
  int teacherId;
  String teacherName;
  String phoneNumber;

  int price;
  String teacherPhoto;
  String teacherPhotoUrlSource;
  int sessionHeaderId;
  String lessonName;
  String sessionDate;
  int videos;
  int quizzes;
  String yearOfStudy;
  String subject;
  int termIndex;
  int yearSubjectId;
  int lessonId;
  String dir;

  RecentSession(
      {this.teacherId,
      this.teacherName,
      this.phoneNumber,
      this.price,
      this.teacherPhoto,
      this.teacherPhotoUrlSource,
      this.sessionHeaderId,
      this.lessonName,
      this.sessionDate,
      this.videos,
      this.quizzes,
      this.yearOfStudy,
      this.subject,
      this.termIndex,
      this.yearSubjectId,
      this.lessonId,
      this.dir});

  RecentSession.fromJson(Map<String, dynamic> json) {
    teacherId = json['teacherId'];
    teacherName = json['teacherName'];
    phoneNumber = json['phoneNumber'];

    price = json['price'];
    teacherPhoto = json['teacherPhoto'];
    teacherPhotoUrlSource = json['teacherPhotoUrlSource'];
    sessionHeaderId = json['sessionHeaderId'];
    lessonName = json['lessonName'];
    sessionDate = json['sessionDate'];
    videos = json['videos'];
    quizzes = json['quizzes'];
    yearOfStudy = json['yearOfStudy'];
    subject = json['subject'];
    termIndex = json['termIndex'];
    yearSubjectId = json['yearSubjectId'];
    lessonId = json['lessonId'];
    dir = json['dir'];
  }
}
