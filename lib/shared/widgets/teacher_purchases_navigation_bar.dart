import 'package:my_school/screens/student_followup_list_screen.dart';
import 'package:my_school/screens/student_followup_piechart_screen.dart';
import 'package:my_school/screens/teacher_purchases_screen.dart';
import 'package:my_school/screens/teacher_revenue_overtime_screen.dart';
import 'package:my_school/screens/teacher_viewsPerLesson_screen.dart';
import 'package:my_school/screens/teacher_views_overtime_screen.dart';
import 'package:my_school/screens/teacher_views_piechart_screen.dart';
import 'package:my_school/screens/teacher_views_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

enum pageIndex { ViewsPerLesson, Views, PieChart, LineChart }

class TeacherPurchasesNavigationBar extends StatefulWidget {
  TeacherPurchasesNavigationBar({this.PageIndex});
  final int PageIndex;

  String navigationUrl;

  @override
  State<TeacherPurchasesNavigationBar> createState() =>
      TeacherPurchasesNavigationBarState();
}

class TeacherPurchasesNavigationBarState
    extends State<TeacherPurchasesNavigationBar> {
  int _selectedPageIndex = 0;
  String lang = CacheHelper.getData(key: "lang");
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      switch (_selectedPageIndex) {
        case 0:
          {
            navigateTo(context, TeacherPurchasesScreen());
            break;
          }
        case 1:
          {
            navigateTo(context, TeacherRevenueOvertimeScreen());
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
            label: lang == "en" ? 'Transactions' : "المعاملات",
          ),
          BottomNavigationBarItem(
            backgroundColor: interfaceColor,
            icon: Icon(Icons.stacked_line_chart_outlined),
            label:
                lang == "en" ? 'Transactions over Time' : "المعاملات عبر الزمن",
          ),
        ],
      ),
    );
  }
}
