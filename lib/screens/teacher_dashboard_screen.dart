import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/teacher_content_management_screen.dart';
import 'package:my_school/screens/teacher_profile_screen.dart';
import 'package:my_school/screens/teacher_purchases_screen.dart';
import 'package:my_school/screens/teacher_viewsPerLesson_screen.dart';
import 'package:my_school/screens/teacher_views_screen.dart';
import 'package:my_school/screens/test_fileUpload.dart';
import 'package:my_school/screens/test_screen.dart';
import 'package:my_school/screens/ticket_screen.dart';
import 'package:my_school/screens/under_construction_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/dashboard_button.dart';

class TeacherDashboardScreen extends StatefulWidget {
  TeacherDashboardScreen({Key key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int Id;
  String FullName;
  String lang;
  @override
  void initState() {
    // TODO: implement initState
    Id = CacheHelper.getData(key: "teacherId");
    FullName = CacheHelper.getData(key: "fullName");
    lang = CacheHelper.getData(key: "lang");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, FullName),
        body: Directionality(
          textDirection: lang.toLowerCase() == "ar"
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
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
                              TeacherProfileScreen(
                                  teacherId: Id, readOnly: false));
                        },
                        'MainData.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "البيانات الرئيسية"
                            : "Main Profile Data",
                        false,
                      ),
                      dashboardButton(
                        context,
                        () {
                          navigateTo(
                              context, TeacherContentManagementScreen(Id));
                        },
                        'sessions.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "إدارة المحتوى"
                            : "Content Management",
                        false,
                      ),
                      dashboardButton(
                        context,
                        () {
                          navigateTo(context, TeacherViewsPerLessonScreen());
                        },
                        'Chart.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "المشاهدات والتفاعلات"
                            : "Views & Interactivity",
                        false,
                      ),
                      dashboardButton(
                        context,
                        () {
                          navigateTo(context, TeacherPurchasesScreen());
                        },
                        'money.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "تحليل الدخل"
                            : "Income Analysis",
                        false,
                      ),
                      dashboardButton(
                        context,
                        () {
                          navigateTo(context, TicketScreen());
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
        ));
  }
}
