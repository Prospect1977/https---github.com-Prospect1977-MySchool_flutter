import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/Quiz_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/teacher_quiz_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/question_image_input.dart';

class TeacherQuizQuestionScreen extends StatefulWidget {
  TeacherQuizQuestionScreen(
      {@required this.TeacherId,
      @required this.QuizId,
      @required this.dir,
      this.question,
      Key key})
      : super(key: key);
  Question question;
  int TeacherId;
  int QuizId;
  String dir;
  @override
  State<TeacherQuizQuestionScreen> createState() =>
      _TeacherQuizQuestionScreenState();
}

class _TeacherQuizQuestionScreenState extends State<TeacherQuizQuestionScreen> {
  List<DropdownMenuItem> QuestionTypes = [];
  String SelectedQuestionType;
  List<Answer> Answers = [];
  TextEditingController QuestionTitleController = new TextEditingController();
  List<TextEditingController> AnswersControllers = [];

  var lang = CacheHelper.getData(key: 'lang');
  var token = CacheHelper.getData(key: 'token');
  void _selectImage(String pickedImage) {
    setState(() {
      widget.question.questionImageUrl = pickedImage;
      widget.question.urlSource = "api";
    });
  }

  void SaveChanges() async {
    if (QuestionTitleController.text == "" &&
        widget.question.questionImageUrl == null) {
      showToast(
          text: widget.dir == "ltr"
              ? "Question is empty!"
              : "نص السؤال لا يجب أن يترك فارغاً!",
          state: ToastStates.ERROR);
      return;
    }
    if (Answers == null) {
      showToast(
          text: widget.dir == "ltr"
              ? "You haven't added any answers!"
              : "لم تقم بإضافة أي إجابات!",
          state: ToastStates.ERROR);
      return;
    } else {
      if (Answers.length < 2 ||
          (SelectedQuestionType == "Example" && Answers.length == 0)) {
        showToast(
            text: widget.dir == "ltr"
                ? "You haven't added enough answer(s)!"
                : "لم تقم بإضافة الحد الأدنى من عدد الإجابات",
            state: ToastStates.ERROR);
        return;
      }
      if (Answers.where((element) => element.isRightAnswer).length == 0) {
        showToast(
            text: widget.dir == "ltr"
                ? "You must flag at least one answer as a right answer!"
                : "يحب تعيين إجابة واحدة على الأقل لتكون هي الإجابة الصحيحة",
            state: ToastStates.ERROR);
        return;
      }
      print('QuestionId: ${widget.question.id}');
      print('QuizId:${widget.QuizId}');
      print('TeacherId:${widget.TeacherId}');
      print(json.encode(widget.question.toJson()));
      widget.question.answers = Answers;
      widget.question.questionType = SelectedQuestionType;
      // var formdata =
      //     FormData.fromMap({"Question": json.encode(widget.question.toJson())});
      DioHelper.postData(
          url: "TeacherQuiz/SaveQuestion",
          lang: lang,
          token: token,
          data: widget.question.toJson(),
          query: {
            "TeacherId": widget.TeacherId,
            "QuizId": widget.QuizId,
            "QuestionId": widget.question.id
          }).then((value) {
        if (value.data["status"] == false) {
          showToast(
              text: widget.dir == "ltr"
                  ? "Unkown error has occured!"
                  : "حدث خطأ ما!",
              state: ToastStates.ERROR);
          navigateAndFinish(context, LoginScreen());
        } else {
          showToast(text: value.data["message"], state: ToastStates.SUCCESS);
          navigateTo(context,
              TeacherQuizScreen(QuizId: widget.QuizId, dir: widget.dir));
        }

        navigateTo(
            context, TeacherQuizScreen(QuizId: widget.QuizId, dir: widget.dir));
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }
  }

  void ReorderAnswers() async {
    String ids = '';
    widget.question.answers.map((e) {
      ids += '${e.id},';
    }).toList();
    ids = ids.substring(0, ids.length - 1);
    print(ids);
    DioHelper.postData(
            url: "TeacherQuiz/ReorderQuestions",
            lang: lang,
            token: token,
            data: {},
            query: {"TeacherId": widget.TeacherId, 'QuestionsList': ids})
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
        // getData();
      }
    });
  }

  void getQuestionTypes() {
    QuestionTypes = [
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            QuestionType(type: "MultipleChoice", dir: widget.dir),
          ),
        ),
        value: "MultipleChoice",
      ),
      if (widget.question == null || SelectedQuestionType == "YesNo")
        DropdownMenuItem(
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white))),
            alignment: widget.dir == "ltr"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              QuestionType(type: "YesNo", dir: widget.dir),
            ),
          ),
          value: "YesNo",
        ),
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            QuestionType(type: "Example", dir: widget.dir),
          ),
        ),
        value: "Example",
      ),
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      print(widget.question.toJson());
    } catch (ex) {}

    if (widget.question != null) {
      Answers = [...widget.question.answers];
      SelectedQuestionType = widget.question.questionType;
      QuestionTitleController.text = widget.question.title;
      Answers.forEach((element) {
        TextEditingController AnswerController = new TextEditingController();
        AnswerController.text = element.title;
        AnswersControllers.add(AnswerController);
      });
    } else {
      SelectedQuestionType = "0";
      QuestionTitleController.text = "";
    }
    getQuestionTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBarComponent(context, widget.dir == "ltr" ? "Question" : "سؤال"),
      body: Directionality(
        textDirection:
            widget.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
        child: Container(
            padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black38),
                      ),
                      child: DropdownButton(
                        //key: ValueKey(1),
                        value: SelectedQuestionType,
                        items: [
                          if (widget.question == null)
                            DropdownMenuItem(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white))),
                                alignment: widget.dir == "ltr"
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Text(
                                  widget.dir == "ltr"
                                      ? "Question Type"
                                      : "نوع السؤال",
                                ),
                              ),
                              value: "0",
                            ),
                          ...QuestionTypes,
                        ],

                        onChanged: (value) {
                          setState(() {
                            SelectedQuestionType = value;
                            if (value == "Example" && Answers.length > 0) {
                              Answers.forEach((element) {
                                element.isRightAnswer = true;
                              });
                            }

                            if ((value == "MultipleChoice" ||
                                    value == "YesNo") &&
                                Answers.length > 0) {
                              Answers.forEach((element) {
                                element.isRightAnswer = false;
                              });
                            }
                            if (value == "YesNo" &&
                                widget.question == null &&
                                Answers.length == 0) {
                              AnswersControllers = [];
                              Answers = [];
                              TextEditingController ctrl1 =
                                  new TextEditingController();
                              TextEditingController ctrl2 =
                                  new TextEditingController();
                              ctrl1.text =
                                  widget.dir == "ltr" ? "True" : "صواب";
                              ctrl2.text =
                                  widget.dir == "ltr" ? "False" : "خطأ";
                              AnswersControllers.add(ctrl1);
                              AnswersControllers.add(ctrl2);

                              Answer MyAnswer1 = Answer.fromJson({
                                "id": 0,
                                "title": widget.dir == "ltr" ? "True" : "صواب",
                                "isRightAnswer": false
                              });
                              Answer MyAnswer2 = Answer.fromJson({
                                "id": 0,
                                "title": widget.dir == "ltr" ? "False" : "خطأ",
                                "isRightAnswer": false
                              });

                              Answers.add(MyAnswer1);
                              Answers.add(MyAnswer2);
                            }
                            widget.question.questionType = value;
                          });
                        },
                        icon: Padding(
                            //Icon at tail, arrow bottom is default icon
                            padding: EdgeInsets.all(0),
                            child: Icon(Icons.keyboard_arrow_down)),
                        iconEnabledColor: Colors.black54, //Icon color
                        style: TextStyle(
                            //te
                            color: Colors.black87, //Font color
                            fontSize: 16 //font size on dropdown button
                            ),
                        underline: Container(),

                        dropdownColor: Colors.white, //dropdown background color
                        //remove underline
                        isExpanded: true, //make true to make width 100%
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  defaultFormField(
                      controller: QuestionTitleController,
                      type: TextInputType.text,
                      maximumLines: 2,
                      onChange: (value) {
                        if (SelectedQuestionType != "0") {
                          if (widget.question == null) {
                            setState(() {
                              widget.question =
                                  new Question.fromJson({"id": 0});
                            });
                          }
                          widget.question.title = value;
                        }
                      },
                      label: widget.dir == "ltr" ? "Question" : "السؤال"),
                  SizedBox(
                    height: 3,
                  ),
                  widget.question == null
                      ? AddImage(
                          dir: widget.dir,
                          selectImage: _selectImage,
                          isDiabled: true)
                      : widget.question.questionImageUrl != null
                          ? Container()
                          : AddImage(
                              dir: widget.dir,
                              selectImage: _selectImage,
                              isDiabled: widget.question.questionType != "0"
                                  ? false
                                  : true),
                  widget.question != null
                      ? widget.question.questionImageUrl != null
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(children: [
                                  Image.network(
                                    '${widget.question.urlSource == "web" ? webUrl : baseUrl0}Sessions/QuestionImages/${widget.question.questionImageUrl}',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black54),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
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
                                                        Navigator.of(ctx).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                          widget.dir == "ltr"
                                                              ? 'Yes'
                                                              : "نعم"),
                                                      onPressed: () {
                                                        setState(() {
                                                          widget.question
                                                                  .questionImageUrl =
                                                              null;
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )));
                                      },
                                    ),
                                  )
                                ]),
                              ),
                            )
                          : Container()
                      : Container(),
                  SelectedQuestionType != "0"
                      ? //----------------------------------------------Choices Banner------------------------------
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: defaultColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          child: Row(
                            children: [
                              Text(
                                getAnswerTitle(
                                    SelectedQuestionType, widget.dir),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              SelectedQuestionType != "YesNo"
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          TextEditingController ctrl1 =
                                              new TextEditingController();

                                          AnswersControllers.add(ctrl1);

                                          Answer MyAnswer1 = Answer.fromJson({
                                            "id": 0,
                                            "title": "",
                                            "isRightAnswer":
                                                widget.question.questionType ==
                                                        "Example"
                                                    ? true
                                                    : false
                                          });

                                          Answers.add(MyAnswer1);
                                          if (widget.question == null) {
                                            widget.question =
                                                new Question.fromJson(
                                                    {"id": 0});
                                            widget.question.answers = [];
                                          }
                                          if (widget.question.answers == null) {
                                            widget.question.answers = [];
                                          }
                                          widget.question.answers
                                              .add(MyAnswer1);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(3),
                                        child: Text(
                                          widget.dir == "ltr"
                                              ? "+ Add an Answer"
                                              : "+ إضافة إجابة",
                                          style: TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(.9),
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                      ),
                                    )
                                  : Container()
                            ],
                          ))
                      : Container(),
                  SizedBox(
                    height: 8,
                  ),
                  ReorderableListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = Answers[index];
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          key: ValueKey(item),
                          children: [
                            Row(children: [
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (SelectedQuestionType != "Example") {
                                          Answers.forEach((element) {
                                            element.isRightAnswer = false;
                                          });
                                          item.isRightAnswer = true;
                                        } else {
                                          item.isRightAnswer = true;
                                        }
                                      });
                                    },
                                    child: Icon(Icons.check_circle,
                                        color: item.isRightAnswer
                                            ? Colors.green
                                            : Colors.black12),
                                  ),
                                  (SelectedQuestionType != "YesNo" &&
                                          item.id == 0)
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.question.answers
                                                  .removeAt(index);
                                              Answers = [
                                                ...widget.question.answers
                                              ];
                                            });
                                          },
                                          child: Icon(Icons.delete,
                                              color:
                                                  Colors.red.withOpacity(0.4)),
                                        )
                                      : Container(),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: defaultFormField(
                                      controller: AnswersControllers[index],
                                      onChange: (value) {
                                        item.title = value;
                                      },
                                      type: TextInputType.text,
                                      label: ""))
                            ]),
                            SizedBox(
                              height: 8,
                            )
                          ]);
                    },
                    itemCount: Answers.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex--;
                        }
                        final tile = Answers.removeAt(oldIndex);
                        Answers.insert(newIndex, tile);
                      });
                      ReorderAnswers();
                    },
                  ),
                  defaultButton(
                      function: SaveChanges,
                      text: widget.dir == "ltr" ? "Save" : "حفظ",
                      foregroundColor: Colors.white,
                      background: Colors.green)
                ],
              ),
            )),
      ),
    );
  }
}

String getAnswerTitle(String QuestionType, String dir) {
  String out;
  switch (QuestionType) {
    case "MultipleChoice":
      out = dir == "ltr" ? "Choices" : "الخيارات";
      break;
    case "Example":
      out = dir == "ltr" ? "Right Answer(s)" : "الإجابة/الإجابات الصحيحة";
      break;
    case "YesNo":
      out = dir == "ltr" ? "Choices" : "الخيارات";
      break;
    case "0":
      out = "";
      break;
  }
  return out;
}

class AddImage extends StatefulWidget {
  AddImage(
      {@required this.dir,
      @required this.selectImage,
      @required this.isDiabled,
      Key key})
      : super(key: key);
  String dir;
  Function selectImage;
  bool isDiabled;
  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black38,
              ),
              borderRadius: BorderRadius.circular(5)),
          margin: EdgeInsets.only(top: 8),
          child: QuestionImageInput(widget.selectImage, widget.isDiabled)),
      Positioned(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3),
          color: Colors.white,
          child: Text(
            widget.dir == "ltr" ? "Add Image" : "أضف صورة",
            style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                backgroundColor: Colors.white),
          ),
        ),
        top: 0,
        left: widget.dir == "ltr" ? 8 : null,
        right: widget.dir == "rtl" ? 8 : null,
      ),
    ]);
  }
}
