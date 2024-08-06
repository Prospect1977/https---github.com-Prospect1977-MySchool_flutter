import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/teacher_quiz_analysis_screen3.dart';
import 'package:my_school/screens/teacher_quiz_screen.dart';
import 'package:my_school/shared/components/components.dart';

import '../models/quiz_analysis_model.dart';
import '../shared/dio_helper.dart';
import '../shared/styles/colors.dart';

class TeacherQuizAnalysisScreen2 extends StatefulWidget {
  TeacherQuizAnalysisScreen2(
      {@required this.sessionHeaderId,
      @required this.dir,
      @required this.lessonName,
      Key key})
      : super(key: key);
  int sessionHeaderId;
  String dir;
  String lessonName;
  @override
  State<TeacherQuizAnalysisScreen2> createState() =>
      _TeacherQuizAnalysisScreen2State();
}

class _TeacherQuizAnalysisScreen2State
    extends State<TeacherQuizAnalysisScreen2> {
  List<QuizInSession> model;
  void getData() {
    DioHelper.getData(url: 'QuizAnalysis/QuizzesInSession', query: {
      "SessionHeaderId": widget.sessionHeaderId,
    }).then((value) {
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => QuizInSession.fromJson(item))
            .toList();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: Scaffold(
          appBar: appBarComponent(context, widget.lessonName),
          body: model == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: EdgeInsets.all(8),
                  child: Directionality(
                    textDirection: widget.dir == "ltr"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: ListView.builder(
                      itemCount: model.length,
                      itemBuilder: (context, index) {
                        var item = model[index];
                        return InkWell(
                          onTap: () {
                            navigateTo(
                                context,
                                TeacherQuizAnalysisScreen3(
                                  quizId: item.quizId,
                                  dir: widget.dir,
                                ));
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: defaultColor),
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    decoration:
                                        BoxDecoration(color: defaultColor),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${widget.dir == "ltr" ? "Quiz:" : "اختبار:"} ${index + 1}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                navigateTo(
                                                    context,
                                                    TeacherQuizScreen(
                                                      QuizId: item.quizId,
                                                      dir: widget.dir,
                                                    ));
                                              },
                                              child: Text(
                                                widget.dir == "ltr"
                                                    ? "Edit"
                                                    : "تحرير",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              " | ",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                navigateTo(
                                                    context,
                                                    TeacherQuizAnalysisScreen3(
                                                      dir: widget.dir,
                                                      quizId: item.quizId,
                                                    ));
                                              },
                                              child: Text(
                                                widget.dir == "ltr"
                                                    ? "Data Analysis"
                                                    : "تحليل البيانات",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                '${widget.dir == "ltr" ? "No. of questions:" : "عدد الأسئلة:"}',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item.questionsCount.toString(),
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.blue.shade700,
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.black54,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                '${widget.dir == "ltr" ? "No. of Students: " : "عدد الطلبة: "}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item.examinersCount.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.black54,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                '${widget.dir == "ltr" ? "Succeeded: " : "الناجحون: "} ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                            Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                item.examinersCount == 0
                                                    ? '0'
                                                    : '${item.succeeded} (${(item.succeeded * 100 / item.examinersCount).toStringAsFixed(0)} %)',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.black54,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                '${widget.dir == "ltr" ? "Failed: " : "الراسبون: "}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                            Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                item.examinersCount == 0
                                                    ? '0'
                                                    : '${item.failed} (${(item.failed * 100 / item.examinersCount).toStringAsFixed(0)} %)',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ));
  }
}
