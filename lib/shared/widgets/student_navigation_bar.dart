import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/student_followup_piechart_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

enum pageIndex { List, PieChart }

class StudentNavigationBar extends StatefulWidget {
  StudentNavigationBar({this.PageIndex, this.StudentId, this.StudentName});
  final int PageIndex;
  final int StudentId;
  final String StudentName;
  String navigationUrl;

  @override
  State<StudentNavigationBar> createState() => StudentNavigationBarState();
}

class StudentNavigationBarState extends State<StudentNavigationBar> {
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
                StudentFollowupListScreen(
                  StudentId: widget.StudentId,
                  StudentName: widget.StudentName,
                ));
            break;
          }
        case 1:
          {
            navigateTo(
                context,
                StudentFollowupPiechartScreen(
                  StudentId: widget.StudentId,
                  StudentName: widget.StudentName,
                ));
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
          icon: Icon(Icons.list),
          label: lang == "en" ? 'Info' : "البيانات",
        ),
        BottomNavigationBarItem(
          backgroundColor: interfaceColor,
          icon: Icon(Icons.pie_chart),
          label: lang == "en" ? 'Charts' : "الرسومات البيانية",
        ),
      ],
    );
  }
}
