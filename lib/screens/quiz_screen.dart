import 'dart:convert';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/Quiz_model.dart';
import 'package:my_school/models/StudentQuiz_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class QuizScreen extends StatefulWidget {
  int StudentId;
  int QuizId;
  String dir;
  String LessonName;

  QuizScreen(
      {this.StudentId,
      @required this.QuizId,
      @required this.dir,
      @required this.LessonName,
      Key key})
      : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String roles = CacheHelper.getData(key: "roles");
  String dir = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  PageController _pageController = PageController();
  List<TextEditingController> textControllers = [];
  QuizModel MyQuiz;
  int currentPage = 0;
  List<int> selectedAnswerIds = [];
  List<StudentAnswer> studentAnswers = [];
  bool showReport = false;
  double quizResult = 0;
  String quizResultAsFraction;
  String quizResultAsPercentage;
  bool readOnly;
  @override
  void initState() {
    super.initState();
    if (roles == "teacher") {
      readOnly = false;
    }
    getQuiz();
  }

  void updateStudentAnswers() {
    studentAnswers = [];
    int i = 0;
    setState(() {
      MyQuiz.Questions.map((item) {
        if (item.questionType != "Example") {
          var isAnswerRight =
              item.answers.firstWhere((m) => m.isRightAnswer == true).id ==
                  selectedAnswerIds[i];
          var stAnswer = new StudentAnswer(
              QuestionId: item.id,
              AnswerId: selectedAnswerIds[i],
              IsAnswerRight: isAnswerRight);
          studentAnswers.add(stAnswer);
          print(stAnswer.IsAnswerRight);
        } else {
          bool isAnswerRight;
          item.answers.map((answer) {
            if (textControllers[i].text.trim().toLowerCase() ==
                answer.title.trim().toLowerCase()) {
              isAnswerRight = true;
            }
          }).toList();

          var stAnswer = new StudentAnswer(
              QuestionId: item.id,
              AnswerText: textControllers[i].text,
              IsAnswerRight: isAnswerRight);
          studentAnswers.add(stAnswer);

          print(stAnswer.AnswerText);
        }
        i++;
      }).toList();
      quizResult = studentAnswers.where((a) => a.IsAnswerRight == true).length /
          MyQuiz.Questions.length;
      quizResultAsFraction = widget.dir == "ltr"
          ? '${studentAnswers.where((a) => a.IsAnswerRight == true).length} / ${MyQuiz.Questions.length}'
          : studentAnswers
                  .where((a) => a.IsAnswerRight == true)
                  .length
                  .toString() +
              '\\' +
              MyQuiz.Questions.length.toString();

      quizResultAsPercentage = (quizResult * 100).toStringAsFixed(1);
    });
  }

  void saveQuiz() {
    //SaveQuiz(int StudentId,int QuizId,DateTime DataDate,[FromBody]IEnumerable<StudentQuestionAnswer> QuizAnswers)
    print(jsonEncode(StudentAnswers(studentAnswers).toJson()));
    if (roles == "Teacher") {
      return;
    }
    DioHelper.postData(
            url: "StudentQuiz",
            query: {
              "QuizId": widget.QuizId,
              "StudentId": widget.StudentId,
              "DataDate": DateTime.now()
            },
            lang: dir == "ltr" ? "en" : "ar",
            data: jsonEncode(StudentAnswers(studentAnswers).toJson()),
            token: token)
        .then(
      (value) {
        print(value.data);
        if (value.data["status"] == false) {
          navigateAndFinish(context, LoginScreen());
        }
        showToast(
            text: widget.dir == "ltr" ? "Saved Successfully" : "تم الحفظ بنجاح",
            state: ToastStates.SUCCESS);
      },
    );
  }

  void getQuiz() {
    DioHelper.getData(
            url: roles == "Teacher" ? "Quiz/getQuizDataForTeacher" : "Quiz",
            query: roles == "Teacher"
                ? {"QuizId": widget.QuizId}
                : {"QuizId": widget.QuizId, "StudentId": widget.StudentId},
            lang: dir == "ltr" ? "en" : "ar",
            token: token)
        .then(
      (value) {
        //   print(value.data);
        if (value.data["status"] == false) {
          navigateAndFinish(context, LoginScreen());
        }
        setState(() {
          print(
              '-----------------------------------${value.data["data"]["finishedQuizData"]["dataDate"]}');
          dynamic dataDate = value.data["data"]["finishedQuizData"]["dataDate"];
          if (dataDate != null) {
            readOnly = true;
            showReport = true;
            getQuizReport();
          } else {
            readOnly = false;
            showReport = false;
            MyQuiz =
                QuizModel.fromJson(value.data["data"]["questionsAndAnswers"]);
            MyQuiz.Questions.map((e) {
              var ctlr = TextEditingController();
              textControllers.add(ctlr);
              selectedAnswerIds.add(0);
            }).toList();
          }
        });
      },
    );
  }

  void getQuizReport() {
    //only fires when widget.readOnly=true
    DioHelper.getData(
            url: "StudentQuiz",
            query: {"QuizId": widget.QuizId, "StudentId": widget.StudentId},
            lang: dir == "ltr" ? "en" : "ar",
            token: token)
        .then(
      (value) {
        print(value.data);
        if (value.data["status"] == false) {
          navigateAndFinish(context, LoginScreen());
        }
        setState(() {
          MyQuiz = QuizModel.fromJson(value.data["data"]["questions"]);
          var stAnswers =
              StudentAnswers.fromJson(value.data["data"]["studentAnswers"]);
          MyQuiz.Questions.map((q) {
            var answer;
            try {
              answer =
                  stAnswers.StuAnswers.firstWhere((a) => a.QuestionId == q.id);
            } catch (_) {
              answer = null;
            }

            if (answer == null) {
              var ctlr = TextEditingController();
              textControllers.add(ctlr);
              selectedAnswerIds.add(0);
            } else {
              var ctlr = TextEditingController();
              if (q.questionType == "Example" && answer.AnswerText != null) {
                ctlr.text = answer.AnswerText;
              }
              textControllers.add(ctlr);
              selectedAnswerIds.add(answer.AnswerId);
            }
          }).toList();
          updateStudentAnswers();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, widget.LessonName),
        body: Column(
          children: [
            MyQuiz == null
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : showReport == false && readOnly == false
                    ? Directionality(
                        textDirection: widget.dir == "ltr"
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PageView(
                              // physics: const NeverScrollableScrollPhysics(),
                              reverse: widget.dir == "ltr" ? false : true,
                              onPageChanged: (value) {
                                setState(() {
                                  currentPage = value;
                                });
                              },
                              controller: _pageController,
                              children:
                                  MyQuiz.Questions.map((item) => Container(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Text(
                                                  widget.dir == "ltr"
                                                      ? 'Question ${currentPage + 1} of ${MyQuiz.Questions.length}'
                                                      : 'السؤال ${currentPage + 1} من ${MyQuiz.Questions.length}',
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                              ),
                                              Divider(),
                                              item.title != null
                                                  ? Text(
                                                      item.title,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              Colors.black54),
                                                    )
                                                  : Container(),
                                              item.questionImageUrl != null
                                                  ? Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        child: Image.network(
                                                            '${item.urlSource == "web" || item.urlSource == "Web" ? webUrl : baseUrl0}Sessions/QuestionImages/${item.questionImageUrl}'),
                                                      ),
                                                    )
                                                  : Container(),
                                              item.questionType == "Example"
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8),
                                                      child: TextField(
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      OutlineInputBorder()),
                                                          // maxLines: 6,
                                                          controller:
                                                              textControllers[
                                                                  currentPage]),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: item.answers
                                                              .map((e) {
                                                            return InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedAnswerIds[
                                                                          currentPage] =
                                                                      e.id;
                                                                });
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  border: Border.all(
                                                                      width: (selectedAnswerIds[currentPage] == e.id)
                                                                          ? 2
                                                                          : 1,
                                                                      color: (selectedAnswerIds[currentPage] ==
                                                                              e.id)
                                                                          ? defaultColor
                                                                          : Colors.black38),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                      (selectedAnswerIds[currentPage] == e.id)
                                                                          ? Icons
                                                                              .radio_button_checked
                                                                          : Icons
                                                                              .radio_button_off,
                                                                      color: (selectedAnswerIds[currentPage] ==
                                                                              e.id)
                                                                          ? defaultColor
                                                                          : Colors.black45,
                                                                      size: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      e.title,
                                                                      style: TextStyle(
                                                                          fontWeight: (selectedAnswerIds[currentPage] == e.id)
                                                                              ? FontWeight
                                                                                  .bold
                                                                              : FontWeight
                                                                                  .normal,
                                                                          color: (selectedAnswerIds[currentPage] == e.id)
                                                                              ? defaultColor
                                                                              : Colors
                                                                                  .black54,
                                                                          fontSize:
                                                                              16),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }).toList()),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      )).toList(),
                            ),
                          ),
                        ),
                        //------------------------------------------------Report Page
                      )
                    : ConditionalBuilder(
                        condition: MyQuiz != null,
                        fallback: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        builder: (context) => Expanded(
                          child: SingleChildScrollView(
                            child: Directionality(
                              textDirection: widget.dir == "ltr"
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0.0),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: quizResult < 0.5
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      child: Text(
                                          widget.dir == "ltr"
                                              ? 'Quiz Result: ${quizResultAsFraction} (${quizResultAsPercentage} %)'
                                              : "نتيجة الإختبار: ${quizResultAsFraction} (${quizResultAsPercentage} %)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: MyQuiz.Questions.length,
                                      itemBuilder: (context, index) {
                                        var item = MyQuiz.Questions[index];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.dir == "ltr"
                                                  ? '${index + 1}) ${item.title}'
                                                  : '${index + 1}) ${item.title}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            item.questionImageUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image.network(
                                                      '${item.urlSource == "web" || item.urlSource == "Web" ? webUrl : baseUrl0}Sessions/QuestionImages/${item.questionImageUrl}',
                                                      width: double.infinity,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child:
                                                        item.questionType ==
                                                                "Example"
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      studentAnswers[
                                                                              index]
                                                                          .AnswerText,
                                                                      style: TextStyle(
                                                                          fontSize: studentAnswers[index].IsAnswerRight == true
                                                                              ? 18
                                                                              : 16,
                                                                          color: studentAnswers[index].IsAnswerRight == true
                                                                              ? Colors.green
                                                                              : Colors.red)),
                                                                  studentAnswers[index]
                                                                              .IsAnswerRight ==
                                                                          null
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(item.answers[0].title, style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic)),
                                                                            ),
                                                                            Container(
                                                                              width: 50,
                                                                              child: Icon(
                                                                                Icons.check_circle,
                                                                                size: 18,
                                                                                color: Colors.green,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              )
                                                            : Container(
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: item
                                                                      .answers
                                                                      .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          i) {
                                                                    return Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.circle,
                                                                              size: studentAnswers[index].IsAnswerRight == null || studentAnswers[index].AnswerId == 0 ? 10 : (studentAnswers[index].IsAnswerRight == true ? (studentAnswers[index].AnswerId == item.answers[i].id ? 12 : 10) : (studentAnswers[index].AnswerId == item.answers[i].id ? 12 : 10)),
                                                                              color: studentAnswers[index].IsAnswerRight == null || studentAnswers[index].AnswerId == 0 ? Colors.black54 : (studentAnswers[index].IsAnswerRight == true ? (studentAnswers[index].AnswerId == item.answers[i].id ? Colors.green : Colors.black54) : (studentAnswers[index].AnswerId == item.answers[i].id ? Colors.red : Colors.black54))),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              item.answers[i].title,
                                                                              style: TextStyle(fontSize: studentAnswers[index].IsAnswerRight == null || studentAnswers[index].AnswerId == 0 ? 14 : (studentAnswers[index].IsAnswerRight == true ? (studentAnswers[index].AnswerId == item.answers[i].id ? 16 : 14) : (studentAnswers[index].AnswerId == item.answers[i].id ? 16 : 14)), color: studentAnswers[index].IsAnswerRight == null || studentAnswers[index].AnswerId == 0 ? Colors.black54 : (studentAnswers[index].IsAnswerRight == true ? (studentAnswers[index].AnswerId == item.answers[i].id ? Colors.green : Colors.black54) : (studentAnswers[index].AnswerId == item.answers[i].id ? Colors.red : Colors.black54)), fontWeight: studentAnswers[index].IsAnswerRight == null || studentAnswers[index].AnswerId == 0 ? FontWeight.normal : (studentAnswers[index].IsAnswerRight == true ? (studentAnswers[index].AnswerId == item.answers[i].id ? FontWeight.bold : FontWeight.normal) : (studentAnswers[index].AnswerId == item.answers[i].id ? FontWeight.bold : FontWeight.normal))),
                                                                            ),
                                                                          ), //-----------------------------------------display the right answer
                                                                          item.answers[i].isRightAnswer == true
                                                                              ? Container(
                                                                                  width: 50,
                                                                                  //padding: EdgeInsets.all(5),
                                                                                  child: Icon(
                                                                                    Icons.check_circle,
                                                                                    size: 18,
                                                                                    color: Colors.green,
                                                                                  ),
                                                                                )
                                                                              : Container(
                                                                                  width: 0.01,
                                                                                )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )),
                                              ],
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            showReport == false && readOnly == false
                ? MyQuiz == null
                    ? Container()
                    : Container(
                        height: 40,
                        padding: EdgeInsets.all(5),
                        child: //currentPage < MyQuiz.Questions.length - 1
                            Directionality(
                          textDirection: widget.dir == "ltr"
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          child: Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: defaultColor,
                                      foregroundColor: Colors.white),
                                  onPressed: currentPage == 0
                                      ? null
                                      : () {
                                          updateStudentAnswers();
                                          _pageController.previousPage(
                                              duration:
                                                  Duration(microseconds: 1000),
                                              curve: Curves.easeInOut);
                                        },
                                  child: Text(widget.dir == "ltr"
                                      ? "< Previous"
                                      : "< السابق")),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: defaultColor,
                                      foregroundColor: Colors.white),
                                  onPressed: currentPage ==
                                          MyQuiz.Questions.length - 1
                                      ? null
                                      : () {
                                          updateStudentAnswers();
                                          _pageController.nextPage(
                                              duration:
                                                  Duration(microseconds: 1000),
                                              curve: Curves.easeInOut);
                                        },
                                  child: Text(widget.dir == "ltr"
                                      ? "Next >"
                                      : "التالي >")),
                              SizedBox(
                                width: 10,
                              ),
                              currentPage == MyQuiz.Questions.length - 1
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white),
                                      onPressed: () {
                                        updateStudentAnswers();
                                        showReport = true;
                                        saveQuiz();
                                      },
                                      child: Text(widget.dir == "ltr"
                                          ? "Finish"
                                          : "إنهاء"))
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                : Container()
          ],
        ));
  }
}
