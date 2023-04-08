import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/student_followup_piechart_screen.dart';
import 'package:my_school/screens/teacher_session_screen.dart';
import 'package:my_school/screens/teacher_session_settings_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

enum pageIndex { List, PieChart }

class TeacherSessionNavigationBar extends StatefulWidget {
  TeacherSessionNavigationBar(
      {this.PageIndex,
      @required this.TeacherId,
      @required this.YearSubjectId,
      @required this.TermIndex,
      @required this.LessonId,
      @required this.LessonName,
      @required this.dir});
  final int PageIndex;
  final int TeacherId;
  int YearSubjectId;
  int TermIndex;
  int LessonId;
  String LessonName;
  String dir;
  String navigationUrl;

  @override
  State<TeacherSessionNavigationBar> createState() =>
      TeacherSessionNavigationBarState();
}

class TeacherSessionNavigationBarState
    extends State<TeacherSessionNavigationBar> {
  int _selectedPageIndex = 0;
  String lang = CacheHelper.getData(key: "lang");
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      switch (_selectedPageIndex) {
        case 0:
          {
            navigateTo(
                context,
                TeacherSessionScreen(
                  LessonId: widget.LessonId,
                  LessonName: widget.LessonName,
                  TeacherId: widget.TeacherId,
                  TermIndex: widget.TermIndex,
                  YearSubjectId: widget.YearSubjectId,
                  dir: widget.dir,
                ));
            break;
          }
        case 1:
          {
            navigateTo(
                context,
                TeacherSessionSettingsScreen(
                  LessonId: widget.LessonId,
                  LessonName: widget.LessonName,
                  TeacherId: widget.TeacherId,
                  TermIndex: widget.TermIndex,
                  YearSubjectId: widget.YearSubjectId,
                  dir: widget.dir,
                ));
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: interfaceColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellow,
        currentIndex: widget.PageIndex,
        // type: BottomNavigationBarType.fixed,  //this is the default value, you can instead type BottomNavigationBarType.shifting for animation effect,
        items: [
          BottomNavigationBarItem(
            backgroundColor: interfaceColor,
            icon: Icon(Icons.list),
            label: lang == "en" ? 'Content List' : "قائمة المحتوى",
          ),
          BottomNavigationBarItem(
            backgroundColor: interfaceColor,
            icon: Icon(Icons.settings),
            label: lang == "en" ? 'Settings' : "الإعدادات",
          ),
        ],
      ),
    );
  }
}
