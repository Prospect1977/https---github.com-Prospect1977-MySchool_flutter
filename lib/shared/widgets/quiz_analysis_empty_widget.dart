import 'package:flutter/material.dart';

import '../cache_helper.dart';

class QuizAnalysisEmptyWidget extends StatelessWidget {
  QuizAnalysisEmptyWidget({Key key}) : super(key: key);
  String lang = CacheHelper.getData(key: 'lang');

  get defaultColor => null;
  @override
  Widget build(BuildContext context) {
    return Center(
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
                  ? "No student passed this quiz so far!"
                  : "لا يوجد طالب خاض هذا الاختبار حتى الأن!",
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
    );
  }
}
