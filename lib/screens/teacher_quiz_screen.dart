import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/Quiz_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/quiz_screen.dart';
import 'package:my_school/screens/teacher_quiz_question.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class TeacherQuizScreen extends StatefulWidget {
  TeacherQuizScreen(
      {@required this.QuizId,
      // @required this.TeacherId,
      // @required this.LessonId,
      @required this.dir,
      Key key})
      : super(key: key);
  int QuizId;
  // int TeacherId;
  // int LessonId;
  String dir;

  @override
  State<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends State<TeacherQuizScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  var token = CacheHelper.getData(key: 'token');
  var TeacherId = CacheHelper.getData(key: 'teacherId');
  bool showReorderTip = true;
  QuizModel quiz = null;
  void getData() async {
    DioHelper.getData(
            url: "TeacherQuiz",
            query: {
              "TeacherId": TeacherId,
              "QuizId": widget.QuizId,
            },
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
      setState(() {
        quiz = QuizModel.fromJson(value.data['data']);
      });
    });
  }

  void ReorderQuestions() async {
    String ids = '';
    quiz.Questions.map((e) {
      ids += '${e.id},';
    }).toList();
    ids = ids.substring(0, ids.length - 1);
    print(ids);
    DioHelper.postData(
        url: "TeacherQuiz/ReorderQuestions",
        lang: lang,
        token: token,
        data: {},
        query: {"TeacherId": TeacherId, 'QuestionsList': ids}).then((value) {
      if (value.data["status"] == false) {
        showToast(
            text: widget.dir == "ltr"
                ? "Unkown error has occured!"
                : "حدث خطأ ما!",
            state: ToastStates.ERROR);
        navigateAndFinish(context, LoginScreen());
      } else {
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
        // getData();
      }
    });
  }

  void DeleteQuestion(int QuestionId) async {
    DioHelper.postData(
            url: "TeacherQuiz/DeleteQuestion",
            lang: lang,
            token: token,
            data: {},
            query: {"TeacherId": TeacherId, 'QuestionId': QuestionId})
        .then((value) {
      if (value.data["status"] == false) {
        showToast(
            text: widget.dir == "ltr"
                ? "Unkown error has occured!"
                : "حدث خطأ ما!",
            state: ToastStates.ERROR);
        navigateAndFinish(context, LoginScreen());
      } else {
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
        getData();
        Navigator.pop(context);
      }
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
      appBar: appBarComponent(context, widget.dir == "ltr" ? "Quiz" : "إختبار"),
      body: quiz == null
          ? Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection:
                  widget.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
              child: Column(
                children: [
                  quiz.Questions.length > 1 && showReorderTip
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber.shade700,
                                ),
                                Expanded(
                                  child: Text(
                                    widget.dir == "ltr"
                                        ? "Tap, Hold, then Drag to reorder items"
                                        : "للترتيب: إضغط طويلا ثم اسحب العنصر رأسيا",
                                    style: TextStyle(
                                        color: Colors.amber.shade700,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      showReorderTip = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 17,
                                  ),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Colors.amber.shade700),
                                color: Colors.amber.withOpacity(0.05)),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: ReorderableListView.builder(
                        itemCount: quiz.Questions.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex--;
                            }
                            final tile = quiz.Questions.removeAt(oldIndex);
                            quiz.Questions.insert(newIndex, tile);
                          });
                          ReorderQuestions();
                        },
                        itemBuilder: (context, index) {
                          var item = quiz.Questions[index];
                          return GestureDetector(
                            key: ValueKey(item),
                            onTap: () {
                              navigateTo(
                                  context,
                                  TeacherQuizQuestionScreen(
                                    TeacherId: TeacherId,
                                    QuizId: widget.QuizId,
                                    question: item,
                                    dir: widget.dir,
                                  ));
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index < 9 && quiz.Questions.length > 9 ? "  " : ""}${(index + 1).toString()}) ',
                                        style: TextStyle(
                                            fontSize: 16, color: defaultColor),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: item.title,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: defaultColor)),
                                                  TextSpan(text: "  "),
                                                  TextSpan(
                                                      text:
                                                          ' ${QuestionType(type: item.questionType, dir: widget.dir)} ',
                                                      style: TextStyle(
                                                          height: 1.5,
                                                          fontSize: widget
                                                                      .dir ==
                                                                  "ltr"
                                                              ? 13
                                                              : 14,
                                                          backgroundColor:
                                                              widget.dir ==
                                                                      "ltr"
                                                                  ? Colors
                                                                      .black38
                                                                  : Colors
                                                                      .white,
                                                          color: widget.dir ==
                                                                  "ltr"
                                                              ? Colors.white
                                                              : Colors
                                                                  .black54)),
                                                ],
                                              ),
                                            ),
                                            // Text(item.title,
                                            //     style: TextStyle(
                                            //         fontSize: 16,
                                            //         color: defaultColor)),
                                            item.questionImageUrl != null
                                                ? SizedBox(
                                                    height: 8,
                                                  )
                                                : Container(),
                                            item.questionImageUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                        '${item.urlSource == "web" || item.urlSource == "Web" ? webUrl : baseUrl0}Sessions/QuestionImages/${item.questionImageUrl}'),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => Directionality(
                                                  textDirection:
                                                      widget.dir == "ltr"
                                                          ? TextDirection.ltr
                                                          : TextDirection.rtl,
                                                  child: AlertDialog(
                                                    titleTextStyle: TextStyle(
                                                        color: defaultColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    title: Text(
                                                        widget.dir == "ltr"
                                                            ? 'Are you sure?'
                                                            : "هل انت متأكد؟"),
                                                    content: Text(
                                                      widget.dir == "ltr"
                                                          ? 'Are you sure that you want to remove this question?'
                                                          : "هل تريد حذف هذا السؤال؟",
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(
                                                            widget.dir == "ltr"
                                                                ? "No"
                                                                : "لا"),
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                            widget.dir == "ltr"
                                                                ? 'Yes'
                                                                : "نعم"),
                                                        onPressed: () {
                                                          DeleteQuestion(
                                                              item.id);
                                                        },
                                                      ),
                                                    ],
                                                  )));

                                          ;
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade800
                                              .withOpacity(0.5),
                                        ),
                                      )
                                    ],
                                  ),
                                  index < quiz.Questions.length - 1
                                      ? Divider(
                                          height: 20,
                                          thickness: .8,
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  quiz.Questions.length > 1
                      ? InkWell(
                          onTap: () {
                            navigateTo(
                                context,
                                QuizScreen(
                                    QuizId: widget.QuizId,
                                    dir: widget.dir,
                                    LessonName: widget.dir == "ltr"
                                        ? "Preview"
                                        : "معاينة"));
                          },
                          child: Container(
                              padding: EdgeInsets.all(5),
                              color: Colors.deepPurple,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    widget.dir == "ltr" ? "Preview" : "معاينة",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  )
                                ],
                              )),
                        )
                      : Container()
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          navigateTo(
              context,
              TeacherQuizQuestionScreen(
                // question: Question(questionType: "0"),
                TeacherId: TeacherId,
                QuizId: widget.QuizId,
                dir: widget.dir,
              ));
          // showModalBottomSheet(
          //     context: context,
          //     builder: (_) {
          //       return SingleChildScrollView(
          //         child: AnimatedPadding(
          //           padding: MediaQuery.of(context).viewInsets,
          //           duration: Duration(milliseconds: 200),
          //           child: Padding(
          //             padding:
          //                 EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          //             child: Directionality(
          //               textDirection: lang == "en"
          //                   ? TextDirection.ltr
          //                   : TextDirection.rtl,
          //               child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     InkWell(
          //                       onTap: () {},
          //                       child: Text(
          //                         lang == "en"
          //                             ? "Multiple Choice"
          //                             : "إختيار من متعدد",
          //                         style: TextStyle(fontSize: 18),
          //                       ),
          //                     ),
          //                     Divider(),
          //                     InkWell(
          //                       onTap: () async {},
          //                       child: Text(
          //                         lang == "en" ? "Yes/No" : "صواب/خطأ",
          //                         style: TextStyle(fontSize: 18),
          //                       ),
          //                     ),
          //                     Divider(),
          //                     InkWell(
          //                       onTap: () {},
          //                       child: Text(
          //                         lang == "en"
          //                             ? "Complete Missing Word"
          //                             : "أكمل",
          //                         style: TextStyle(fontSize: 18),
          //                       ),
          //                     ),
          //                   ]),
          //             ),
          //           ),
          //         ),
          //       );
          //     });
        },
      ),
    );
  }
}
