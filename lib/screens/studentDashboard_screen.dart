import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentDashboard_cubit.dart';
import 'package:my_school/cubits/StudentDashboard_states.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDailySchedule_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen1.dart';
import 'package:my_school/screens/studentProfile_screen.dart';
import 'package:my_school/screens/studentSelectedSubjects_screen.dart';
import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/ticket_screen.dart';
import 'package:my_school/screens/under_construction_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/dashboard_button.dart';

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
  bool isStudentHasParent = CacheHelper.getData(key: "studentHasParent");
  String roles = CacheHelper.getData(key: "roles");
  @override
  Widget build(BuildContext context) {
    if (widget.Id > 0) {
      //pageCode(Id, FullName);
      return Scaffold(
        appBar: appBarComponent(context, widget.FullName,
            backButtonPage: CacheHelper.getData(key: "roles") == "Student"
                ? null
                : ParentsLandingScreen()),
        body: pageBody(context),
      );
    } else {
      return BlocProvider(
        create: (context) => StudentDashboardCubit()..getStudent(),
        child: BlocConsumer<StudentDashboardCubit, StudentDashboardStates>(
            listener: (context, state) {},
            builder: (context, state) {
              var cubit = StudentDashboardCubit.get(context);
              widget.FullName = cubit.FullName;
              widget.Id = cubit.Id;
              widget.Gender = cubit.Gender;
              widget.SchoolTypeId = cubit.SchoolTypeId;
              widget.YearOfStudyId = cubit.YearOfStudyId;
              if (state is UnAuthendicatedState) {
                navigateAndFinish(context, LoginScreen());
              }
              return (state is SuccessState)
                  ? Scaffold(
                      appBar: appBarComponent(context, cubit.FullName),
                      body: pageBody(context),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      );
    }
  }

  Widget pageBody(context) {
    return Directionality(
      textDirection:
          lang.toLowerCase() == "ar" ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 150,
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
                                widget.YearOfStudyId == null) ||
                            (isStudentHasParent && roles == "Student")
                        ? null
                        : () {
                            navigateTo(context,
                                StudentSelectedSubjectsScreen(widget.Id));
                          },
                    isStudentHasParent && roles == "Student"
                        ? 'SelectSubjects_disabled.png'
                        : 'SelectSubjects.png',
                    lang.toString().toLowerCase() == "ar"
                        ? "إختر المواد الدراسية"
                        : "Select Learning Subjects",
                    isStudentHasParent && roles == "Student" ? true : false,
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
                        ? "مذاكرة حسب المادة"
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
          ],
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