import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/student_finished_quiz_model.dart';
import 'package:my_school/screens/quiz_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';

import '../shared/styles/colors.dart';

class StudentFinishedQuizzesScreen extends StatefulWidget {
  StudentFinishedQuizzesScreen(
      {this.studentId, this.finishedQuizzesIds, this.dir, Key key})
      : super(key: key);
  List<dynamic> finishedQuizzesIds;
  int studentId;
  String dir;

  @override
  State<StudentFinishedQuizzesScreen> createState() =>
      _StudentFinishedQuizzesScreenState();
}

class _StudentFinishedQuizzesScreenState
    extends State<StudentFinishedQuizzesScreen> {
  String lang = CacheHelper.getData(key: 'lang');
  String roles = CacheHelper.getData(key: "roles");
  TextEditingController _quizCodeController = TextEditingController();
  List<StudentFinishedQuiz> model;
  void getData() async {
    DioHelper.getData(url: 'ReportStudentProgress/GetFinishedQuizzes', query: {
      "StudentId": widget.studentId,
      "QuizzesIds": widget.finishedQuizzesIds
    }).then((value) {
      setState(() {
        print(value.data["data"]);
        model = (value.data["data"] as List)
            .map((item) => StudentFinishedQuiz.fromJson(item))
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
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Solved Quizzes" : "الاختبارات المحلولة"),
      body: model == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: model.length,
              itemBuilder: (context, index) {
                var item = model[index];
                return Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: InkWell(
                    onTap: () {
                      bool readOnly;
                      bool allowRetry;
                      if (roles.contains("Student")) {
                        if (item.degree > 0) {
                          readOnly = true;
                          allowRetry = true;
                        } else {
                          readOnly = false;
                          allowRetry = false;
                        }
                      } else {
                        readOnly = true;
                        allowRetry = false;
                      }
                      if (item.isQuizLimited) {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              content: TextField(
                                controller: _quizCodeController,
                                decoration: InputDecoration(
                                    hintText: widget.dir == "ltr"
                                        ? "Please enter the code"
                                        : "برجاء إدخال الكود"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    if (_quizCodeController.text ==
                                        item.limitedQuizCode) {
                                      Navigator.of(ctx).pop();
                                      navigateTo(
                                          context,
                                          QuizScreen(
                                            StudentId: widget.studentId,
                                            QuizId: item.quizId,
                                            LessonName: item.lessonName,
                                            dir: widget.dir,
                                          ));
                                    } else {
                                      showToast(
                                          text: lang == "en"
                                              ? "The provided code is not right!"
                                              : "الكود الذي ادخلته خطأ!",
                                          state: ToastStates.ERROR);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        navigateTo(
                            context,
                            QuizScreen(
                              StudentId: widget.studentId,
                              QuizId: item.quizId,
                              LessonName: item.lessonName,
                              dir: widget.dir,
                            ));
                      }
                    },
                    child: Card(
                      //----------------------------------------------Card
                      elevation: 1,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: defaultColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Row(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getImage(
                                    widget.dir == "ltr" ? "left" : "right",
                                    60.0,
                                    60.0,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.lessonName,
                                          style: TextStyle(color: defaultColor),
                                        ),
                                        if (item.isQuizLimited)
                                          SizedBox(
                                            height: 3,
                                          ),
                                        if (item.isQuizLimited)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 0),
                                            decoration: BoxDecoration(
                                                color: Colors.amber.shade600,
                                                border: Border.all(
                                                    color:
                                                        Colors.amber.shade800),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Text(
                                              widget.dir == "ltr"
                                                  ? "Exclusive"
                                                  : "حصري",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          formatDate(
                                            item.dataDate,
                                            widget.dir == "ltr" ? "en" : "ar",
                                          ),
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontStyle: FontStyle.italic),
                                        )
                                      ],
                                    ),
                                  ),
                                ]),
                            SizedBox(
                              height: 3,
                            ),
                            Container(
                              height: 4.5,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    color: Colors.black12,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: item.degree / 100,
                                    heightFactor: 1,
                                    child: Container(
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Widget getImage(String align, double width, double height) {
  if (align == "left") {
    align = "right";
  } else {
    align = "left";
  }

  return Image.asset(
    'assets/images/Quiz_$align.png',
    width: width,
    height: height,
  );
}
