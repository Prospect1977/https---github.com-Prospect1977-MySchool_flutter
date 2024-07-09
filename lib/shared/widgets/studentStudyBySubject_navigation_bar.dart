import 'package:my_school/screens/studentLearnBySubjectScreen1.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen2.dart';
import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/student_followup_piechart_screen.dart';
import 'package:my_school/screens/student_video_notes_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../../screens/student_favorites_bysubject_screen.dart';

enum pageIndex { Lessons, VideoNotes }

class StudentStudyBySubjectNavigationBar extends StatefulWidget {
  StudentStudyBySubjectNavigationBar({
    this.PageIndex,
    this.StudentId,
  });
  final int PageIndex;
  final int StudentId;
  String navigationUrl;

  @override
  State<StudentStudyBySubjectNavigationBar> createState() =>
      StudentStudyBySubjectNavigationBarState();
}

class StudentStudyBySubjectNavigationBarState
    extends State<StudentStudyBySubjectNavigationBar> {
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
                StudentLearnBySubjectScreen2(
                  YearSubjectId: CacheHelper.getData(key: "yearSubjectId"),
                  dir: CacheHelper.getData(key: "dir"),
                  studentId: widget.StudentId,
                  SubjectName: CacheHelper.getData(key: "subjectName"),
                ));

            break;
          }
        case 1:
          {
            navigateTo(
                context,
                StudentVideoNotesScreen(
                  YearSubjectId: CacheHelper.getData(key: "yearSubjectId"),
                  dir: CacheHelper.getData(key: "dir"),
                  studentId: widget.StudentId,
                  SubjectName: CacheHelper.getData(key: "subjectName"),
                ));
            break;
          }
        case 2:
          {
            navigateTo(
                context,
                StudentFavoritesBySubjectScreen(
                  YearSubjectId: CacheHelper.getData(key: "yearSubjectId"),
                  dir: CacheHelper.getData(key: "dir"),
                  StudentId: widget.StudentId,
                  SubjectName: CacheHelper.getData(key: "subjectName"),
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
            label: lang == "en" ? 'Lessons' : "الدروس",
          ),
          BottomNavigationBarItem(
            backgroundColor: interfaceColor,
            icon: Icon(Icons.note_alt_outlined),
            label: lang == "en" ? 'Video Notes' : "ملاحظات الفيدوهات",
          ),
          BottomNavigationBarItem(
            backgroundColor: interfaceColor,
            icon: Icon(Icons.star),
            label: lang == "en" ? 'Favorites' : "المفضلات",
          ),
        ],
      ),
    );
  }
}
