import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

class TeacherQuizAnalysisScreen extends StatefulWidget {
  const TeacherQuizAnalysisScreen({Key key}) : super(key: key);

  @override
  State<TeacherQuizAnalysisScreen> createState() =>
      _TeacherQuizAnalysisScreenState();
}

class _TeacherQuizAnalysisScreenState extends State<TeacherQuizAnalysisScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context,
            lang == "en" ? "Quizzes Analysis" : "تحليل نتائج الإختبارات"),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 93,
                  backgroundColor: defaultColor,
                  child: CircleAvatar(
                    child: Image.asset("assets/images/quiz-analysis.png"),
                    backgroundColor: Color.fromRGBO(200, 200, 200, 1),
                    radius: 90,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  lang == "en"
                      ? "No student passed any of your quizzes so far!"
                      : "لا يوجد طالب خاض أي من إختباراتك حتى الأن!",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: lang == "en" ? 22 : 20,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                  textDirection:
                      lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                ),
              ],
            ),
          ),
        ));
  }
}
