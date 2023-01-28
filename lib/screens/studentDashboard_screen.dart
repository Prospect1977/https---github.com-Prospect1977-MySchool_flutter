import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentDashboard_cubit.dart';
import 'package:my_school/cubits/StudentDashboard_states.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDailySchedule_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentProfile_screen.dart';
import 'package:my_school/screens/studentSelectedSubjects_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

class StudentDashboardScreen extends StatefulWidget {
  int Id;
  String FullName;
  String Gender;
  int SchoolTypeId;
  int YearOfStudyId;
  StudentDashboardScreen(
      {this.Id = 0,
      this.FullName = '',
      this.Gender = null,
      this.SchoolTypeId = null,
      this.YearOfStudyId = null});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String lang = CacheHelper.getData(key: "lang");

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          button(context, () {
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
              Icons.filter_frames,
              lang.toString().toLowerCase() == "ar"
                  ? "البيانات الرئيسية${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (غير مكتملة)" : ""}"
                  : "Main Profile Data${(widget.SchoolTypeId == null || widget.YearOfStudyId == null) ? " (Not Completed)" : ""}",
              Colors.white,
              false),
          button(
              context,
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? null
                  : () {
                      navigateTo(
                          context, StudentSelectedSubjectsScreen(widget.Id));
                    },
              Icons.check_box_outlined,
              lang.toString().toLowerCase() == "ar"
                  ? "إختر المواد الدراسية"
                  : "Select Learning Subjects",
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? Colors.black26
                  : Colors.white,
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? true
                  : false),
          button(
              context,
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? null
                  : () {
                      navigateTo(
                          context,
                          StudentDailyScheduleScreen(
                              widget.Id, widget.FullName));
                    },
              Icons.video_collection_sharp,
              lang.toString().toLowerCase() == "ar" ? "مذاكرتي" : "My Study",
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? Colors.black26
                  : Colors.white,
              (widget.SchoolTypeId == null || widget.YearOfStudyId == null)
                  ? true
                  : false),
        ],
      ),
    );
  }
}

Widget button(context, onClick, icon, title, color, bool isDisabled) {
  return InkWell(
    onTap: onClick,
    child: Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDisabled ? Colors.white60 : defaultColor, width: 2),
          borderRadius: BorderRadius.circular(5),
          color: isDisabled ? Colors.black54 : color,
        ),
        child: Row(children: [
          Icon(
            icon,
            color: isDisabled ? Colors.white60 : defaultColor,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.white60 : defaultColor),
              textAlign: TextAlign.center,
            ),
          )
        ]),
      ),
    ),
  );
}
