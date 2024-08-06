import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/teacher_quiz_analysis_screen2.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../models/quiz_analysis_model.dart';

class TeacherQuizAnalysisScreen extends StatefulWidget {
  const TeacherQuizAnalysisScreen({Key key}) : super(key: key);

  @override
  State<TeacherQuizAnalysisScreen> createState() =>
      _TeacherQuizAnalysisScreenState();
}

class _TeacherQuizAnalysisScreenState extends State<TeacherQuizAnalysisScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  List<QuizAnalysisLesson> model;
  TextEditingController searchController;
  int teacherId = CacheHelper.getData(key: "teacherId");
  void getData(String searchString) {
    DioHelper.getData(
            url: 'QuizAnalysis/SearchByLessonName',
            query: {"TeacherId": teacherId, "SearchString": searchString})
        .then((value) {
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => QuizAnalysisLesson.fromJson(item))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context,
            lang == "en" ? "Quizzes Analysis" : "تحليل نتائج الإختبارات"),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(children: [
            Stack(
              children: [
                Directionality(
                    textDirection:
                        lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                    child: defaultFormField(
                        controller: searchController,
                        type: TextInputType.text,
                        onChange: (value) {
                          if (value.length > 2) {
                            getData(value);
                          } else {
                            setState(() {
                              model = null;
                            });
                          }
                        },
                        label: lang == "en"
                            ? "Search by  lesson name"
                            : "بحث عن عنوان الدرس")),
                Positioned(
                    top: 16,
                    left: lang == "ar" ? 10 : null,
                    right: lang == "en" ? 10 : null,
                    child: Icon(
                      Icons.search,
                      color: Colors.black38,
                      size: 30,
                    ))
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
                child: model == null
                    ? Container()
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          var item = model[index];
                          return Directionality(
                            textDirection: item.dir == "ltr"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: InkWell(
                              onTap: () {
                                navigateTo(
                                    context,
                                    TeacherQuizAnalysisScreen2(
                                      sessionHeaderId: item.sessionHeaderId,
                                      dir: item.dir,
                                      lessonName: item.name,
                                    ));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: defaultColor),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        decoration:
                                            BoxDecoration(color: defaultColor),
                                        child: Text(
                                          '${item.subjectName} - ${item.yearOfStudy} - ${item.dir == "ltr" ? "Term:" : "الترم:"} ${item.termIndex}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${item.dir == "ltr" ? "Quizzes: " : "الاختبارات: "} ${item.quizzesCount}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          );
                        },
                        itemCount: model.length,
                      ))
          ]),
        ));
  }
}
