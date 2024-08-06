import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentDashboard_cubit.dart';
import 'package:my_school/cubits/StudentDashboard_states.dart';
import 'package:my_school/models/student_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/screens/studentDailySchedule_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen1.dart';
import 'package:my_school/screens/studentProfile_screen.dart';
import 'package:my_school/screens/studentSelectedSubjects_screen.dart';
import 'package:my_school/screens/student_favorites_all_screen.dart';
import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/ticket_screen.dart';
import 'package:my_school/screens/under_construction_screen.dart';
import 'package:my_school/screens/wallet_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/dashboard_button.dart';
import 'package:my_school/shared/widgets/videoTestScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class StudentDashboardScreen extends StatefulWidget {
  int Id;
  String FullName;
  String Gender;
  int SchoolTypeId;
  int YearOfStudyId;
  StudentDashboardScreen(
      {this.Id = 0,
      this.FullName,
      this.Gender,
      this.SchoolTypeId,
      this.YearOfStudyId});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String lang = CacheHelper.getData(key: "lang");
  bool isStudentHasParent = CacheHelper.getData(key: "isStudentHasParent");
  String roles = CacheHelper.getData(key: "roles");
  void _checkAppVersion() async {
    await checkAppVersion();
    bool isUpdated = CacheHelper.getData(key: "isLatestVersion");
    if (isUpdated == false) {
      navigateTo(context, RequireUpdateScreen());
    }
  }

  bool isLoading = false;
  void getStudent() async {
    CacheHelper.getData(key: 'token');

    var q = {'UserId': CacheHelper.getData(key: 'userId')};
    print(q);
    isLoading = false;
    if (CacheHelper.getData(key: 'studentData') != null &&
        roles.contains("Student")) {
      setState(() {
        print(CacheHelper.getData(key: 'studentData'));

        var stData = StudentModel.fromJson(
            jsonDecode(CacheHelper.getData(key: 'studentData')));

        widget.Id = stData.studentId;
        widget.FullName = stData.fullName;
        widget.Gender = stData.gender;
        widget.YearOfStudyId = stData.yearOfStudyId;
        widget.SchoolTypeId = stData.schoolTypeId;
        isStudentHasParent = stData.isStudentHasParent;
        //  isLoading = false;
      });
    } else {
      DioHelper.getData(
        query: q,
        // token: token,
        url: "StudentMainDataByUserId",
      ).then((value) {
        if (value.data["status"] == false &&
            value.data["message"] == "SessionExpired") {
          handleSessionExpired(context);
        }
        print(value.data["data"]);
        var stData = StudentModel.fromJson(value.data["data"]);
        CacheHelper.saveData(
            key: 'studentData', value: jsonEncode(value.data["data"]));

        setState(() {
          widget.Id = stData.studentId;
          widget.FullName = stData.fullName;
          widget.Gender = stData.gender;
          widget.YearOfStudyId = stData.yearOfStudyId;
          widget.SchoolTypeId = stData.schoolTypeId;
          isStudentHasParent = stData.isStudentHasParent;
          //  isLoading = false;
        });
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAppVersion();
    print(isStudentHasParent);
    if (widget.Id == 0) {
      getStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.Id > 0) {
      //pageCode(Id, FullName);
      return Scaffold(
        floatingActionButton: roles.contains("Student")
            ? FloatingActionButton(
                backgroundColor: defaultColor,
                child: Image.asset(
                  'assets/images/wallet.png',
                  width: 30,
                ),
                onPressed: () {
                  navigateTo(context, WalletScreen());
                })
            : Container(),
        appBar: !(CacheHelper.getData(key: "roles") == "Student")
            ? appBarComponent(context, widget.FullName,
                backButtonPage: CacheHelper.getData(key: "roles") == "Student"
                    ? null
                    : ParentsLandingScreen())
            : null,
        body: pageBody(context),
      );
    } else {
      print(CacheHelper.getData(key: 'fullName'));
      return Scaffold(
        appBar: appBarComponent(context, CacheHelper.getData(key: 'fullName')),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : pageBody(context),
      );
    }
  }

  Widget pageBody(context) {
    return Directionality(
      textDirection:
          lang.toLowerCase() == "ar" ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(
            top: CacheHelper.getData(key: "roles") == "Student" ? 8 : 0,
            left: 8,
            right: 8,
            bottom: 0),
        child: Container(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  children: [
                    dashboardButton(
                      context,
                      () {
                        navigateTo(
                            context,
                            StudentProfileScreen(
                              widget.Id,
                              FullName: widget.FullName,
                              Gender: widget.Gender,
                              SchoolTypeId: widget.SchoolTypeId,
                              YearOfStudyId: widget.YearOfStudyId,
                            ));
                      },
                      'MainData.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "البيانات الرئيسية${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (غير مكتملة)" : ""}"
                          : "Main Profile Data${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (Not Completed)" : ""}",
                      false,
                    ),
                    dashboardButton(
                      context,
                      (widget.SchoolTypeId == null ||
                              widget.YearOfStudyId == null)
                          ? null
                          : isStudentHasParent && roles.contains("Student")
                              ? () {
                                  showToast(
                                      text: lang == "ar"
                                          ? "من حق ولي الأمر فقط إختيار المواد الدراسية"
                                          : "Only your parent is allowed to select subjects!",
                                      state: ToastStates.ERROR);
                                  return;
                                }
                              : () {
                                  navigateTo(context,
                                      StudentSelectedSubjectsScreen(widget.Id));
                                },
                      'SelectSubjects.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "إختر المواد الدراسية"
                          : "Select Learning Subjects",
                      false,
                    ),
                    dashboardButton(
                      context,
                      (widget.SchoolTypeId == null ||
                              widget.YearOfStudyId == null)
                          ? null
                          : () {
                              navigateTo(
                                  context,
                                  StudentDailyScheduleScreen(
                                      widget.Id, widget.FullName));
                            },
                      'Calendar.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "الجدول اليومي"
                          : "Daily Schedule",
                      false,
                    ),
                    dashboardButton(
                      context,
                      (widget.SchoolTypeId == null ||
                              widget.YearOfStudyId == null)
                          ? null
                          : () {
                              navigateTo(context,
                                  StudentLearnBySubjectScreen1(widget.Id));
                            },
                      'StudyBySubject.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "دراسة حسب المادة"
                          : "Study by Subject",
                      false,
                    ),
                    dashboardButton(
                      context,
                      (widget.SchoolTypeId == null ||
                              widget.YearOfStudyId == null)
                          ? null
                          : () {
                              navigateTo(
                                  context,
                                  StudentFollowupListScreen(
                                      StudentId: widget.Id,
                                      StudentName: widget.FullName));
                            },
                      'Chart.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "المتابعة"
                          : "Follow Up",
                      false,
                    ),
                    dashboardButton(
                      context,
                      (widget.SchoolTypeId == null ||
                              widget.YearOfStudyId == null)
                          ? null
                          : () {
                              navigateTo(
                                  context,
                                  TicketScreen(
                                    StudentId: widget.Id,
                                  ));
                            },
                      'Chat.png',
                      lang.toString().toLowerCase() == "ar"
                          ? "تواصل معنا"
                          : "Contact us",
                      false,
                    ),
                  ],
                ),
              ),
              Center(
                child: InkWell(
                    onTap: () {
                      navigateTo(
                          context,
                          StudentFavoritesAllScreen(
                            StudentId: widget.Id,
                          ));
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade700,
                              size: 35,
                            ),
                            Positioned(
                              top: 3,
                              left: 3,
                              child: Icon(
                                Icons.star,
                                color: Colors.amber.shade300,
                                size: 29,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Gridtile (String lang,Widget icon,String Title,Function onTap){
//   return GridTile(child: Container(color:Colors.orange.withOpacity(0.7),child:Column(children: [
//           Container(height: 150,child: Center(child:Icon(Icons.filter_frames)),),lang.toString().toLowerCase() == "ar"
//                   ? "البيانات الرئيسية${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (غير مكتملة)" : ""}"
//                   : "Main Profile Data${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (Not Completed)" : ""}",
//               Colors.white,
//               false)
//           ],)));
// }
