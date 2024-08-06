import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/teacher_quiz_analysis_screen4.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../models/quiz_analysis_model.dart';
import '../shared/dio_helper.dart';

class TeacherQuizAnalysisScreen3 extends StatefulWidget {
  TeacherQuizAnalysisScreen3(
      {@required this.quizId, @required this.dir, Key key})
      : super(key: key);
  int quizId;

  String dir;
  @override
  State<TeacherQuizAnalysisScreen3> createState() =>
      _TeacherQuizAnalysisScreen3State();
}

class _TeacherQuizAnalysisScreen3State
    extends State<TeacherQuizAnalysisScreen3> {
  List<QuizQuestionAnalysis> model;
  int examiners;
  void getData() async {
    await DioHelper.getData(url: 'QuizAnalysis/QuestionsByQuiz', query: {
      "QuizId": widget.quizId,
    }).then((value) {
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => QuizQuestionAnalysis.fromJson(item))
            .toList();
        examiners = value.data["additionalData"];
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
          appBar: appBarComponent(context,
              widget.dir == "ltr" ? "Answers Analysis" : "تحليل الإجابات"),
          body: model == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Directionality(
                    textDirection: widget.dir == "ltr"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: Column(children: [
                      InkWell(
                        onTap: () {
                          navigateTo(
                              context,
                              TeacherQuizAnalysisScreen4(
                                quizId: widget.quizId,
                              ));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.dir == "ltr"
                                  ? "Show Students List"
                                  : "إظهار لائحة الطلبة",
                              style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: model.length == 0
                            ? Center(
                                child: Directionality(
                                textDirection: lang == "en"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: Text(
                                    lang == "en"
                                        ? "This quiz has no question!"
                                        : "هذا الاختبار لا يوجد به اسئلة!",
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 26,
                                        fontStyle: FontStyle.italic)),
                              ))
                            : ListView.builder(
                                itemCount: model.length,
                                itemBuilder: (context, index) {
                                  var item = model[index];
                                  int SumOfUsersWhoAnswered = item.answers.fold(
                                      0,
                                      (previous, current) =>
                                          previous +
                                          current
                                              .studentsWhoSelectedThisAnswer);
                                  int SumOfUsersWhoAnsweredRight = item.answers
                                      .where((m) => m.isRightAnswer)
                                      .fold(
                                          0,
                                          (previous, current) =>
                                              previous +
                                              current
                                                  .studentsWhoSelectedThisAnswer);
                                  return Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: defaultColor),
                                        borderRadius: BorderRadius.circular(5)),
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                              color: defaultColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (item.url != null)
                                          SizedBox(
                                            height: 8,
                                          ),
                                        if (item.url != null)
                                          Image.network(
                                            item.urlSource == "api"
                                                ? '${baseUrl0}Sessions/QuestionImages/${item.url}'
                                                : '${webUrl}Sessions/QuestionImages/${item.url}',
                                            width: double.infinity,
                                          ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        //--------------------------------------------Answers
                                        Column(children: [
                                          ListView.separated(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) {
                                              return Divider(
                                                  color: Colors.black54);
                                            },
                                            itemCount: item.answers.length,
                                            itemBuilder: (context, idx) {
                                              var answer = item.answers[idx];
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      answer.title,
                                                      style: TextStyle(
                                                          color:
                                                              answer.isRightAnswer
                                                                  ? Colors.green
                                                                      .shade700
                                                                  : Colors.red
                                                                      .shade700,
                                                          fontWeight: answer
                                                                  .isRightAnswer
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                    ),
                                                  ),
                                                  Container(
                                                      width: 100,
                                                      child: Text(
                                                          answer.studentsWhoSelectedThisAnswer ==
                                                                      0 ||
                                                                  examiners == 0
                                                              ? "0"
                                                              : '${answer.studentsWhoSelectedThisAnswer} (${(answer.studentsWhoSelectedThisAnswer * 100 / examiners).toStringAsFixed(0)}%)',
                                                          style: TextStyle(
                                                              color: answer
                                                                      .isRightAnswer
                                                                  ? Colors.green
                                                                      .shade700
                                                                  : Colors.red
                                                                      .shade700,
                                                              fontWeight: answer
                                                                      .isRightAnswer
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal)))
                                                ],
                                              );
                                            },
                                          ),
                                          //---------------------------example question case
                                          if (examiners -
                                                      item.studentsWhoSkipped -
                                                      SumOfUsersWhoAnsweredRight >
                                                  0 &&
                                              item.type.toLowerCase() ==
                                                  "example")
                                            Divider(
                                              color: Colors.black54,
                                            ),
                                          if (examiners -
                                                      item.studentsWhoSkipped -
                                                      SumOfUsersWhoAnsweredRight >
                                                  0 &&
                                              item.type.toLowerCase() ==
                                                  "example")
                                            Row(children: [
                                              Expanded(
                                                child: Text(
                                                  widget.dir == "ltr"
                                                      ? "Wrong answers"
                                                      : "إجابات خاطئة",
                                                  style: TextStyle(
                                                    color: Colors.red.shade700,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                  width: 100,
                                                  child: Text(
                                                      '${examiners - item.studentsWhoSkipped - SumOfUsersWhoAnsweredRight} (${((examiners - item.studentsWhoSkipped - SumOfUsersWhoAnsweredRight) * 100 / examiners).toStringAsFixed(0)}%)',
                                                      style: TextStyle(
                                                        color:
                                                            Colors.red.shade700,
                                                      )))
                                            ]),
                                          //--------------------------------------No answer case
                                          if (item.studentsWhoSkipped > 0)
                                            Divider(
                                              color: Colors.black54,
                                            ),
                                          if (item.studentsWhoSkipped > 0)
                                            Row(children: [
                                              Expanded(
                                                child: Text(
                                                  widget.dir == "ltr"
                                                      ? "Did not answer"
                                                      : "لم يُحدد إجابة",
                                                  style: TextStyle(
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                  width: 100,
                                                  child: Text(
                                                      '${item.studentsWhoSkipped} (${(item.studentsWhoSkipped * 100 / examiners).toStringAsFixed(0)}%)',
                                                      style: TextStyle(
                                                        color: Colors.black45,
                                                      )))
                                            ]),
                                        ])
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ]),
                  ),
                ),
        ));
  }
}
