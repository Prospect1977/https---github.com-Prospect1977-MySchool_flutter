import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:my_school/screens/quiz_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/quiz_analysis_empty_widget.dart';

import '../models/quiz_analysis_model.dart';
import '../shared/dio_helper.dart';
import 'package:intl/intl.dart' as intl;

class TeacherQuizAnalysisScreen4 extends StatefulWidget {
  TeacherQuizAnalysisScreen4({this.quizId, Key key}) : super(key: key);
  int quizId;

  @override
  State<TeacherQuizAnalysisScreen4> createState() =>
      _TeacherQuizAnalysisScreen4State();
}

class _TeacherQuizAnalysisScreen4State
    extends State<TeacherQuizAnalysisScreen4> {
  List<QuizStudentDegree> model;
  String orderBy = 'DataDate';
  String lang = CacheHelper.getData(key: 'lang');
  String dir;
  String lessonName;
  void getData() async {
    model = null;
    await DioHelper.getData(
        url: 'QuizAnalysis/StudentsByQuiz',
        query: {"QuizId": widget.quizId, "OrderBy": orderBy}).then((value) {
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => QuizStudentDegree.fromJson(item))
            .toList();
        lessonName = value.data["additionalData"]["lessonName"];
        dir = value.data["additionalData"]["dir"];
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
          appBar: appBarComponent(
              context, lang == "en" ? "Students List" : "قائمة الطلبة"),
          body: model == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: model.length == 0
                      ? QuizAnalysisEmptyWidget()
                      : Column(
                          children: [
                            frame(
                                borderColor: Colors.black26,
                                textDirection: lang == "en"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                title:
                                    lang == "en" ? "Order By" : "الترتيب حسب",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (orderBy != "DataDate") {
                                              orderBy = "DataDate";
                                              getData();
                                            }
                                          });
                                        },
                                        child: Container(
                                          child: Text(
                                            lang == "en"
                                                ? "Date (Descending)"
                                                : "التاريخ (تنازلي)",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: orderBy == "DataDate"
                                                    ? Colors.green.shade800
                                                    : Colors.black54),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: orderBy == "DataDate"
                                                  ? Colors.green
                                                      .withOpacity(0.2)
                                                  : Colors.black
                                                      .withOpacity(0.05),
                                              border: Border.all(
                                                  color: orderBy == "DataDate"
                                                      ? Colors.green
                                                          .withOpacity(0.85)
                                                      : Colors.black38),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (orderBy != "FullName") {
                                              orderBy = "FullName";
                                              getData();
                                            }
                                          });
                                        },
                                        child: Container(
                                          child: Text(
                                            lang == "en"
                                                ? "Student Name"
                                                : "اسم الطلب",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: orderBy == "FullName"
                                                    ? Colors.green.shade800
                                                    : Colors.black54),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: orderBy == "FullName"
                                                  ? Colors.green
                                                      .withOpacity(0.2)
                                                  : Colors.black
                                                      .withOpacity(0.05),
                                              border: Border.all(
                                                  color: orderBy == "FullName"
                                                      ? Colors.green
                                                          .withOpacity(0.85)
                                                      : Colors.black38),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            SizedBox(
                              height: 18,
                            ),
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      Divider(color: Colors.black54),
                                  itemCount: model.length,
                                  itemBuilder: (context, index) {
                                    var item = model[index];
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: InkWell(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              QuizScreen(
                                                QuizId: widget.quizId,
                                                dir: dir,
                                                LessonName: lessonName,
                                                StudentId: item.studentId,
                                                ReadOnly: true,
                                              ));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 160,
                                                child: Text(
                                                  item.fullName,
                                                  style: TextStyle(
                                                      color:
                                                          Colors.blue.shade800),
                                                )),
                                            Container(
                                                width: 60,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '${item.degree.toStringAsFixed(0)} %',
                                                  style: TextStyle(
                                                      color: item.degree >= 50
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors
                                                              .red.shade700),
                                                  textDirection:
                                                      TextDirection.ltr,
                                                )),
                                            Expanded(
                                                child: Row(
                                              children: [
                                                Text(
                                                    intl.DateFormat('dd/MM/yy')
                                                        .format(item.dataDate)
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                if (item.quizAccessCode != null)
                                                  Expanded(
                                                    child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.black38,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Center(
                                                          child: Text(
                                                            item.quizAccessCode,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                  )
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                )),
    );
  }
}
