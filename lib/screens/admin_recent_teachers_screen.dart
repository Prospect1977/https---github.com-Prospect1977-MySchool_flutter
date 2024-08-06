import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';

import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/styles/colors.dart';
import '../shared/widgets/date_filter_button.dart';

class AdminRecentTeachersScreen extends StatefulWidget {
  const AdminRecentTeachersScreen({Key key}) : super(key: key);

  @override
  State<AdminRecentTeachersScreen> createState() =>
      _AdminRecentTeachersScreenState();
}

class _AdminRecentTeachersScreenState extends State<AdminRecentTeachersScreen> {
  List<RecentTeacher> model;
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
  TextEditingController searchController = TextEditingController();
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

  Future<void> getData() async {
    await DioHelper.getData(
            url: 'Admin/RecentTeachers',
            query: _filterBy == "all"
                ? {'ShowAll': true}
                : searchController.text == ""
                    ? {'StartDate': fromDate, 'EndDate': toDate}
                    : {'SearchString': searchController.text})
        .then((value) {
      if (value.data['status'] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => RecentTeacher.fromJson(item))
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
        appBar: appBarComponent(context, "المُعلمين"),
        body: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _filterBy == "all"
                          ? ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _filterBy = "all";
                                  searchController.text = "";
                                });
                                getData();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  textStyle: TextStyle(fontSize: 12)),
                              child: Text("الكل"),
                            )
                          : TextButton(
                              onPressed: () {
                                setState(() {
                                  _filterBy = "all";
                                  searchController.text = "";
                                });
                                getData();
                              },
                              style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(fontSize: 12),
                                  foregroundColor:
                                      Color.fromARGB(255, 94, 94, 94)),
                              child: Text("الكل"),
                            ),
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
                myDivider(),
                Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: defaultFormField(
                          controller: searchController,
                          type: TextInputType.name,
                          label: "بحث",
                          suffix: Icons.cancel_outlined,
                          suffixPressed: () {
                            setState(() {
                              searchController.text = "";

                              getData();
                            });
                          },
                          onChange: ((value) {
                            if (value.length > 2) {
                              _filterBy = "";
                              getData();
                            }
                          })),
                    )),
                myDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: model.length,
                      itemBuilder: (context, index) {
                        var item = model[index];
                        return TeacherWidget(item);
                      },
                    ),
                  ),
                )
              ]));
  }
}

class TeacherWidget extends StatelessWidget {
  TeacherWidget(this.t, {Key key}) : super(key: key);
  RecentTeacher t;
  @override
  Widget build(BuildContext context) {
    var dataDate = DateTime.parse(t.dataDate);
    return InkWell(
      onTap: () {
        CacheHelper.saveData(key: "teacherId", value: t.id);
        CacheHelper.saveData(key: "fullName", value: t.fullName);

        navigateTo(context, TeacherDashboardScreen());
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
                  Text(t.fullName),
                  Text(
                      '${getDayName(dataDate.weekday, "ar")} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}'),
                  Text(t.email),
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

class RecentTeacher {
  int id;
  String fullName;
  String email;
  String phoneNumber;
  String dataDate;
  String teacherPhoto;
  String teacherPhotoUrlSource;

  RecentTeacher(
      {this.id,
      this.fullName,
      this.email,
      this.phoneNumber,
      this.dataDate,
      this.teacherPhoto,
      this.teacherPhotoUrlSource});

  RecentTeacher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    dataDate = json['dataDate'];
    teacherPhoto = json['teacherPhoto'];
    teacherPhotoUrlSource = json['teacherPhotoUrlSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['dataDate'] = this.dataDate;
    data['teacherPhoto'] = this.teacherPhoto;
    data['teacherPhotoUrlSource'] = this.teacherPhotoUrlSource;
    return data;
  }
}
