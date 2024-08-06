import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/admin_recent_parents_screen.dart';
import 'package:my_school/screens/admin_recent_teachers_screen.dart';
import 'package:my_school/screens/admin_teacher_privilages_screen.dart';
import 'package:my_school/screens/admin_tickets_screen.dart';

import '../shared/components/components.dart';
import '../shared/widgets/dashboard_button.dart';
import 'admin_recent_sessions_screen.dart';
import 'curriculum_landing_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, "Admin Panel"),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: double.infinity,
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
                      navigateTo(context, AdminRecentTeachersScreen());
                    },
                    'teacher.png',
                    "المُعلمين",
                    false,
                  ),
                  dashboardButton(
                    context,
                    () {
                      navigateTo(context, AdminRecentParentsScreen());
                    },
                    'parent.png',
                    "أولياء الأمور والطلبة",
                    false,
                  ),
                  dashboardButton(
                    context,
                    () {
                      navigateTo(context, AdminRecentSessionsScreen());
                    },
                    'empty-content.png',
                    "الدروس",
                    false,
                  ),
                  dashboardButton(
                    context,
                    () {
                      navigateTo(context, CurriculumLandingScreen());
                    },
                    'lessons.png',
                    "إدارة دروس المنهج",
                    false,
                  ),
                  dashboardButton(
                    context,
                    () {
                      navigateTo(context, AdminTicketsScreen());
                    },
                    'Chat.png',
                    "الشكاوى",
                    false,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
