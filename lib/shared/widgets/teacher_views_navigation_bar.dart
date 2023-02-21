import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/student_followup_piechart_screen.dart';
import 'package:my_school/screens/teacher_viewsPerLesson_screen.dart';
import 'package:my_school/screens/teacher_views_overtime_screen.dart';
import 'package:my_school/screens/teacher_views_piechart_screen.dart';
import 'package:my_school/screens/teacher_views_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

enum pageIndex { ViewsPerLesson, Views, PieChart, LineChart }

class TeacherViewsNavigationBar extends StatefulWidget {
  TeacherViewsNavigationBar({this.PageIndex});
  final int PageIndex;

  String navigationUrl;

  @override
  State<TeacherViewsNavigationBar> createState() =>
      TeacherViewsNavigationBarState();
}

class TeacherViewsNavigationBarState extends State<TeacherViewsNavigationBar> {
  int _selectedPageIndex = 0;
  String lang = CacheHelper.getData(key: "lang");
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      switch (_selectedPageIndex) {
        case 0:
          {
            navigateTo(context, TeacherViewsPerLessonScreen());
            break;
          }
        case 1:
          {
            navigateTo(context, TeacherViewsScreen());
            break;
          }
        case 2:
          {
            navigateTo(context, TeacherViewsPiechartScreen());
            break;
          }
        case 3:
          {
            navigateTo(context, TeacherViewsOvertimeScreen());
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _selectPage,
      backgroundColor: interfaceColor,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.yellow,
      currentIndex: widget.PageIndex,
      // type: BottomNavigationBarType.fixed,  //this is the default value, you can instead type BottomNavigationBarType.shifting for animation effect,
      items: [
        BottomNavigationBarItem(
          backgroundColor: interfaceColor,
          icon: Icon(Icons.adjust_rounded),
          label: lang == "en" ? 'Lessons Views' : "مشاهدات الدروس",
        ),
        BottomNavigationBarItem(
          backgroundColor: interfaceColor,
          icon: Icon(Icons.list),
          label: lang == "en" ? 'Subjects Views' : "مشاهدات المناهج",
        ),
        BottomNavigationBarItem(
          backgroundColor: interfaceColor,
          icon: Icon(Icons.pie_chart),
          label: lang == "en" ? 'Charts' : "الرسومات البيانية",
        ),
        BottomNavigationBarItem(
          backgroundColor: interfaceColor,
          icon: Icon(Icons.stacked_line_chart_outlined),
          label: lang == "en" ? 'Views over Time' : "المشاهدات عبر الزمن",
        ),
      ],
    );
  }
}
