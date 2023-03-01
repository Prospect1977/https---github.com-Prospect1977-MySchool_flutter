import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/teacher_viewsPerLesson_screen.dart';
import 'package:my_school/screens/teacher_views_screen.dart';
import 'package:my_school/screens/test_fileUpload.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

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
                  height: MediaQuery.of(context).size.height - 300,
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5),
                    children: [
                      button(
                        context,
                        () {
                          navigateTo(context, TestFileUpload());
                        },
                        'MainData.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "البيانات الرئيسية"
                            : "Main Profile Data",
                        false,
                      ),
                      button(
                        context,
                        () {},
                        'sessions.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "إدارة المحتوى"
                            : "Content Management",
                        false,
                      ),
                      button(
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
                      button(
                        context,
                        () {
                          navigateTo(context, TeacherViewsPerLessonScreen());
                        },
                        'money.png',
                        lang.toString().toLowerCase() == "ar"
                            ? "تحليل الدخل"
                            : "Income Analysis",
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

Widget button(context, onClick, imageName, title, isDisabled) {
  return InkWell(
    onTap: onClick,
    child: Card(
      elevation: 3,
      // margin: EdgeInsets.only(horizontal: 10, vertical: 10),
      color: Color.fromARGB(255, 240, 240, 240),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: defaultColor.withOpacity(.4)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width / 5.5,
            height: MediaQuery.of(context).size.width / 5.5,
            child: Image.asset(
              'assets/images/$imageName',
            ),
          )),
          Container(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 15,
                  color: isDisabled ? Colors.black38 : defaultColor),
              textAlign: TextAlign.center,
            ),
          )
        ]),
      ),
    ),
  );
}
