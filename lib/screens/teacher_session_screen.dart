import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/models/teacher_lesson.dart';
//import 'package:my_school/models/StudentSessionHeaderDetail.dart';
import 'package:my_school/models/teacher_session.dart';
import 'package:my_school/providers/TeacherSessionProvider.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/teacher_quiz_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/teacher_file_input.dart';
import 'package:my_school/shared/widgets/teacher_session_navigation_bar.dart';
import 'package:my_school/shared/widgets/video_input.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dio/dio.dart' as dio;

import 'package:http_parser/http_parser.dart';

import 'dart:io';

class TeacherSessionScreen extends StatefulWidget {
  int TeacherId;
  int YearSubjectId;
  int TermIndex;
  int LessonId;
  String LessonName;
  String dir;
  TeacherSessionScreen(
      {@required this.TeacherId,
      @required this.YearSubjectId,
      @required this.TermIndex,
      @required this.LessonId,
      @required this.LessonName,
      @required this.dir,
      Key key})
      : super(key: key);

  @override
  State<TeacherSessionScreen> createState() => _TeacherSessionScreenState();
}

class _TeacherSessionScreenState extends State<TeacherSessionScreen> {
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  TextEditingController titleController = new TextEditingController();
  var showLessons = false;
  // TeacherSession sessionData = null;
  TeacherLessons lessonsData;
  bool showReorderTip = true;
  //the following function is only used for the video procedures:
  void getData() async {
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  void getLessons() async {
    DioHelper.getData(
            url: 'TeacherContentManager/getLessons',
            query: {
              'TeacherId': widget.TeacherId,
              "YearSubjectId": widget.YearSubjectId,
              "TermIndex": widget.TermIndex
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        lessonsData = TeacherLessons.fromJson(value.data["data"]);
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void ActivateSessionDetail(int SessionDetailId) async {
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .ActivateSessionDetail(context, SessionDetailId, widget.TeacherId);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  void DeactivateSessionDetail(int SessionDetailId) async {
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .DeactivateSessionDetail(context, SessionDetailId, widget.TeacherId);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  void _uploadVideoThumnail(int VideoId) async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 700,
    );
    if (imageFile == null) {
      return;
    }
    String filename = await imageFile.path.split("/").last;

    dio.FormData formData = new dio.FormData.fromMap({
      "image": await dio.MultipartFile.fromFile(imageFile.path,
          filename: filename, contentType: new MediaType('file', '*/*')),
      "type": "file"
    });
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .UploadVideoThumnail(context, VideoId, formData);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  void _startEditTitle(ctx, {String title, int sessionDetailId}) {
    setState(() {
      titleController.text = title;
    });

    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: Duration(milliseconds: 200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(new Radius.circular(5)),
                              ),
                              hintText: widget.dir == "ltr"
                                  ? "Add your comment"
                                  : ""),
                          controller: titleController,
                          onSubmitted: (t) {
                            updateTitle(sessionDetailId: sessionDetailId);
                          },
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateTitle(sessionDetailId: sessionDetailId);
                              },
                              child: Text(widget.dir == "ltr" ? "Save" : "حفظ"),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                    widget.dir == "ltr" ? "Cancel" : "إلغاء",
                                    style: TextStyle(color: Colors.black54)))
                          ],
                        )
                      ]),
                ),
              ),
            ),
          );
        });
  }

  void updateTitle({int sessionDetailId}) async {
    if (titleController.text == "") {
      return;
    }
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .updateTitle(
            context: context,
            sessionDetailId: sessionDetailId,
            TeacherId: widget.TeacherId,
            Title: titleController.text);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  void ReorderSessionDetails(List<TeacherSessionDetail> reorderedItems) async {
    String ids = '';
    reorderedItems.map((e) {
      ids += '${e.id},';
    }).toList();
    ids = ids.substring(0, ids.length - 1);
    print(ids);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .ReorderSessionDetails(context, widget.TeacherId, ids);
    await Provider.of<TeacherSessionProvider>(context, listen: false)
        .getData(context, widget.TeacherId, widget.LessonId);
  }

  @override
  void initState() {
    // TODO: implement initState
    print(
        "--------------------------------------TeacherId:${widget.TeacherId}");
    print("--------------------------------------LessonId:${widget.LessonId}");

    getLessons();
    //for the button navigation bar:
  }

  @override
  Widget build(BuildContext context) {
    String align = widget.dir == "ltr" ? "left" : "right";
    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<TeacherSessionProvider>(context, listen: false)
            .getData(context, widget.TeacherId, widget.LessonId);
      },
      child: Scaffold(
        appBar: appBarComponent(context, widget.LessonName),
        body: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
              width: 25,
              margin: EdgeInsets.only(right: 7),
              child: lessonsData == null
                  ? Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black26,
                      size: 45,
                    )
                  : GestureDetector(
                      child: Image.asset(
                        "assets/images/${showLessons ? 'expand_left_pink.png' : 'expand_right_pink.png'}",
                        width: 25,
                        height: 50,
                        opacity: AlwaysStoppedAnimation(1),
                      ),
                      onTap: () {
                        setState(() {
                          showLessons = !showLessons;
                          print(showLessons);
                        });
                      },
                    )),
          showLessons == false
              //----------------------------------------------Session Details
              ? Expanded(
                  child: FutureBuilder(
                      future: Provider.of<TeacherSessionProvider>(context,
                              listen: false)
                          .getData(context, widget.TeacherId, widget.LessonId),
                      builder: ((context, snapshot) =>
                          Consumer<TeacherSessionProvider>(
                              builder: (ctx, model, child) {
                            // setState(() {
                            //   print("set state called!");
                            //   //-------------------------------------------------Potential problem:-----------------------------
                            //   sessionData = model.session;
                            // });
                            return model.isLoading == true
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : model.session.teacherSessionDetails.length ==
                                        0
                                    ? EmptyContentWidget(widget.dir)
                                    : Directionality(
                                        textDirection: widget.dir == "ltr"
                                            ? TextDirection.ltr
                                            : TextDirection.rtl,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  model.session
                                                              .lessonDescription ==
                                                          null
                                                      ? Container()
                                                      : Container(
                                                          alignment: widget
                                                                      .dir ==
                                                                  "ltr"
                                                              ? Alignment
                                                                  .centerLeft
                                                              : Alignment
                                                                  .centerRight,
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 7),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .purple
                                                                  .withOpacity(
                                                                      0.05),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      5),
                                                              border: Border.all(
                                                                  color: defaultColor
                                                                      .withOpacity(
                                                                          0.4),
                                                                  width: 1)),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                model.session
                                                                            .lessonDescription ==
                                                                        null
                                                                    ? ""
                                                                    : model
                                                                        .session
                                                                        .lessonDescription,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .purple
                                                                        .shade300),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  model.session.id == 0 ||
                                                          model.isSessionActive ==
                                                              true
                                                      ? Container()
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .lightbulb,
                                                                  color: Colors
                                                                      .amber
                                                                      .shade700,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    widget.dir ==
                                                                            "ltr"
                                                                        ? "This content is not visible for visitors, tap the settings button below"
                                                                        : "هذا المحتوى غير مرئي للمتصفح، انقر على زر الإعدادات اسفل",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .amber
                                                                            .shade700,
                                                                        fontStyle:
                                                                            FontStyle.italic),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .amber
                                                                        .shade700),
                                                                color: Colors
                                                                    .amber
                                                                    .withOpacity(
                                                                        0.05)),
                                                          ),
                                                        ),
                                                  model.session.teacherSessionDetails
                                                                  .length >
                                                              1 &&
                                                          showReorderTip
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .lightbulb,
                                                                  color: Colors
                                                                      .amber
                                                                      .shade700,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    widget.dir ==
                                                                            "ltr"
                                                                        ? "Tap, Long Hold with Drag to reorder items"
                                                                        : "للترتيب: إضغط طويلا مع سحب العنصر رأسيا",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .amber
                                                                            .shade700,
                                                                        fontStyle:
                                                                            FontStyle.italic),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      showReorderTip =
                                                                          false;
                                                                    });
                                                                  },
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 17,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .amber
                                                                        .shade700),
                                                                color: Colors
                                                                    .amber
                                                                    .withOpacity(
                                                                        0.05)),
                                                          ),
                                                        )
                                                      : Container(),
                                                  Expanded(
                                                    child: Container(
                                                      //to be revised
                                                      height: double.infinity,
                                                      child: ReorderableListView
                                                          .builder(
                                                        itemCount: model
                                                            .session
                                                            .teacherSessionDetails
                                                            .length,
                                                        onReorder: (oldIndex,
                                                            newIndex) {
                                                          if (oldIndex <
                                                              newIndex) {
                                                            newIndex--;
                                                          }
                                                          var tempList = [
                                                            ...model.session
                                                                .teacherSessionDetails
                                                          ];
                                                          final tile =
                                                              tempList.removeAt(
                                                                  oldIndex);
                                                          tempList.insert(
                                                              newIndex, tile);

                                                          ReorderSessionDetails(
                                                              tempList);
                                                        },
                                                        itemBuilder:
                                                            (context, index) {
                                                          var item = model
                                                                  .session
                                                                  .teacherSessionDetails[
                                                              index];
                                                          return Item(
                                                            key: ValueKey(item),
                                                            item: item,
                                                            teacherSession:
                                                                model.session,
                                                            widget: widget,
                                                            align: align,
                                                            UploadVideoThumbnail: () =>
                                                                _uploadVideoThumnail(
                                                                    item.videoId),
                                                            RenameSessionDetail: () =>
                                                                _startEditTitle(
                                                                    context,
                                                                    sessionDetailId:
                                                                        item.id,
                                                                    title: item
                                                                        .title),
                                                            ActivateSessionDetail:
                                                                () =>
                                                                    ActivateSessionDetail(
                                                                        item.id),
                                                            DeactivateSessionDetail:
                                                                () =>
                                                                    DeactivateSessionDetail(
                                                              item.id,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ])));
                          }))))
              //----------------------------------------------Lessons List
              : Expanded(
                  child: lessonsData.Lessons.length == 0
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(color: defaultColor))),
                            child: ListView.separated(
                              separatorBuilder: (context, index) {
                                var item = lessonsData.Lessons[index];
                                if (item.blockedFromAddingSessions) {
                                  return SizedBox(
                                    height: 6,
                                  );
                                }
                                return Divider(
                                  color: defaultColor,
                                  thickness: 0.7,
                                );
                              },
                              itemCount: lessonsData.Lessons.length,
                              itemBuilder: (context, index) {
                                var item = lessonsData.Lessons[index];
                                return InkWell(
                                  onTap: item.blockedFromAddingSessions
                                      ? () {
                                          showToast(
                                              text: widget.dir == "ltr"
                                                  ? "There is no content for main units!"
                                                  : "لا يوجد محتوى للأبواب الرئيسية!",
                                              state: ToastStates.ERROR);
                                        }
                                      : () {
                                          navigateTo(
                                              context,
                                              TeacherSessionScreen(
                                                  TeacherId: widget.TeacherId,
                                                  YearSubjectId:
                                                      widget.YearSubjectId,
                                                  TermIndex: widget.TermIndex,
                                                  LessonId: item.id,
                                                  LessonName: item.lessonName,
                                                  dir: widget.dir));
                                        },
                                  child: Directionality(
                                    textDirection: widget.dir == "ltr"
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: item.parentLessonId != null
                                                  ? 15
                                                  : 0),
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(
                                                  item.blockedFromAddingSessions
                                                      ? 8
                                                      : 0),
                                              decoration: BoxDecoration(
                                                  color: lessonsData.Lessons
                                                              .where((m) =>
                                                                  m.parentLessonId ==
                                                                  item.id).length >
                                                          0
                                                      ? defaultColor
                                                      : Colors.white),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.lessonName,
                                                    style: TextStyle(
                                                        color: lessonsData.Lessons.where((m) =>
                                                                        m.parentLessonId ==
                                                                        item.id)
                                                                    .length >
                                                                0
                                                            ? Colors.white
                                                            : defaultColor
                                                                .withAlpha(200),
                                                        fontStyle: item.parentLessonId == null
                                                            ? FontStyle.normal
                                                            : FontStyle.italic,
                                                        fontSize:
                                                            item.parentLessonId ==
                                                                    null
                                                                ? 20
                                                                : 18,
                                                        fontWeight:
                                                            item.parentLessonId ==
                                                                    null
                                                                ? FontWeight.bold
                                                                : FontWeight.normal),
                                                  ),
                                                  item.blockedFromAddingSessions
                                                      ? Container()
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 8),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                size: 15,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                  item.dataDate !=
                                                                          null
                                                                      ? formatDate(
                                                                          DateTime.parse(item
                                                                              .dataDate),
                                                                          widget.dir == "ltr"
                                                                              ? "en"
                                                                              : "ar")
                                                                      : "",
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      color: Colors
                                                                          .black54)),
                                                            ],
                                                          ),
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                          item.blockedFromAddingSessions
                                              ? Container()
                                              : Container(
                                                  width: 35,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .video_collection,
                                                            size: 18,
                                                            color: item.videos >
                                                                    0
                                                                ? Colors.green
                                                                    .shade700
                                                                : Colors
                                                                    .black26,
                                                          ),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(
                                                            item.videos
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: item.videos >
                                                                      0
                                                                  ? Colors.green
                                                                      .shade800
                                                                  : Colors
                                                                      .black26,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.quiz,
                                                            size: 18,
                                                            color: item.quizzes >
                                                                    0
                                                                ? Colors.green
                                                                    .shade700
                                                                : Colors
                                                                    .black26,
                                                          ),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(
                                                            item.quizzes
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: item.quizzes >
                                                                      0
                                                                  ? Colors.green
                                                                      .shade800
                                                                  : Colors
                                                                      .black26,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.file_copy,
                                                            size: 18,
                                                            color:
                                                                item.documents >
                                                                        0
                                                                    ? Colors
                                                                        .green
                                                                        .shade700
                                                                    : Colors
                                                                        .black26,
                                                          ),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(
                                                            item.documents
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: item.documents >
                                                                      0
                                                                  ? Colors.green
                                                                      .shade800
                                                                  : Colors
                                                                      .black26,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                )
        ]),
        ///////////////////-------------------Potential error--------------------
        bottomNavigationBar:
            Provider.of<TeacherSessionProvider>(context, listen: false)
                        .session !=
                    null
                ? Provider.of<TeacherSessionProvider>(context, listen: false)
                            .session
                            .id ==
                        0
                    ? null
                    : TeacherSessionNavigationBar(
                        LessonId: widget.LessonId,
                        LessonName: widget.LessonName,
                        TeacherId: widget.TeacherId,
                        TermIndex: widget.TermIndex,
                        YearSubjectId: widget.YearSubjectId,
                        dir: widget.dir,
                        PageIndex: 0)
                : null,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (_) {
                  return SingleChildScrollView(
                    child: AnimatedPadding(
                      padding: MediaQuery.of(context).viewInsets,
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.black.withOpacity(0.85),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Directionality(
                          textDirection: lang == "en"
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Provider.of<TeacherSessionProvider>(context,
                                                listen: false)
                                            .session
                                            .teacherSessionDetails
                                            .where((m) => m.type == "Promo")
                                            .length ==
                                        0
                                    ? InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => Dialog(
                                                child: UploadProgressDialog(
                                                    TeacherId: widget.TeacherId,
                                                    LessonId: widget.LessonId,
                                                    IsPromo: true,
                                                    getData: getData)),
                                          );
                                        },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.personal_video,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                lang == "en"
                                                    ? "Add Demo"
                                                    : "إضافة ديمو",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white70),
                                              )
                                            ]),
                                      )
                                    : Container(),
                                Provider.of<TeacherSessionProvider>(context,
                                                listen: false)
                                            .session ==
                                        null
                                    ? Container()
                                    : Provider.of<TeacherSessionProvider>(
                                                    context,
                                                    listen: false)
                                                .session
                                                .teacherSessionDetails
                                                .where((m) => m.type == "Promo")
                                                .length ==
                                            0
                                        ? Divider(
                                            color: Colors.white54,
                                            thickness: 0.5,
                                          )
                                        : Container(),
                                InkWell(
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => Dialog(
                                          child: UploadProgressDialog(
                                              TeacherId: widget.TeacherId,
                                              LessonId: widget.LessonId,
                                              IsPromo: false,
                                              getData: getData)),
                                    );
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.ondemand_video,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          lang == "en"
                                              ? "Add Video"
                                              : "إضافة فيديو",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white70),
                                        )
                                      ]),
                                ),
                                Divider(
                                  color: Colors.white54,
                                  thickness: 0.5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await DioHelper.postData(
                                        url: "TeacherSession/TeacherCreateQuiz",
                                        lang: CacheHelper.getData(key: 'lang'),
                                        token:
                                            CacheHelper.getData(key: 'token'),
                                        query: {
                                          'TeacherId': widget.TeacherId,
                                          "LessonId": widget.LessonId,
                                          "DataDate": DateTime.now(),
                                          "UserId":
                                              CacheHelper.getData(key: 'userId')
                                        }).then(
                                      (value) {
                                        print(value.data["data"]);
                                        if (value.data["status"] == false &&
                                            value.data["message"] ==
                                                "SessionExpired") {
                                          handleSessionExpired(context);
                                          return;
                                        } else if (value.data["status"] ==
                                            false) {
                                          showToast(
                                              text: value.data["message"],
                                              state: ToastStates.ERROR);
                                          return;
                                        }
                                        if (value.data["status"] == true) {
                                          Navigator.pop(context);
                                          navigateTo(
                                              context,
                                              TeacherQuizScreen(
                                                  QuizId: value.data["data"],
                                                  // TeacherId: widget.TeacherId,
                                                  // LessonId: widget.LessonId,
                                                  dir: widget.dir));
                                          Provider.of<TeacherSessionProvider>(
                                                  context,
                                                  listen: false)
                                              .getData(
                                                  context,
                                                  widget.TeacherId,
                                                  widget.LessonId);
                                        }
                                      },
                                    ).catchError((error) {
                                      showToast(
                                          text: error.toString(),
                                          state: ToastStates.ERROR);
                                    });
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          lang == "en"
                                              ? "Add Quiz"
                                              : "إضافة إختبار",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white70),
                                        )
                                      ]),
                                ),
                                Divider(
                                  color: Colors.white54,
                                  thickness: 0.5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await UploadFile(
                                        LessonId: widget.LessonId,
                                        TeacherId: widget.TeacherId,
                                        context: context,
                                        getData: getData);
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.file_open_outlined,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          lang == "en"
                                              ? "Add PDF"
                                              : "إضافة  PDF",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white70),
                                        )
                                      ]),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}

//------------------------------------------------Components----------------------------
class Item extends StatelessWidget {
  Item({
    Key key,
    @required this.item,
    @required this.widget,
    @required this.teacherSession,
    @required this.align,
    @required this.RenameSessionDetail,
    @required this.ActivateSessionDetail,
    @required this.DeactivateSessionDetail,
    @required this.UploadVideoThumbnail,
  }) : super(key: key);

  final TeacherSessionDetail item;

  final TeacherSessionScreen widget;
  final String align;
  final TeacherSession teacherSession;

  final Function RenameSessionDetail;
  final Function ActivateSessionDetail;
  final Function DeactivateSessionDetail;
  final Function UploadVideoThumbnail;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (item.type == "Video" || item.type == "Promo") {
          navigateTo(
              context,
              VideoScreen(
                StudentId: 0,
                VideoId: item.videoId,
                VideoUrl: item.videoUrl,
                aspectRatio: item.aspectRatio,
                UrlSource: item.urlSource,
                Title: item.title,
                CoverUrl:
                    item.coverUrlSource == "web" || item.coverUrlSource == "Web"
                        ? "${webUrl}Sessions/VideoCovers/${item.videoCover}"
                        : "${baseUrl0}Sessions/VideoCovers/${item.videoCover}",
                // SessionHeaderId: teacherSession.id,
                LessonName: widget.LessonName,
                LessonDescription: teacherSession.lessonDescription == null
                    ? ""
                    : teacherSession.lessonDescription,
                dir: widget.dir,
                TeacherName: widget.LessonName,
                VideoName: item.title,
              ));
        }
        if (item.type == "Quiz") {
          navigateTo(
              context,
              TeacherQuizScreen(
                QuizId: item.quizId,
                // LessonId: widget.LessonId,
                // TeacherId: widget.TeacherId,
                dir: widget.dir,
              ));
        }
        if (item.type == "Document") {
          var docUrl =
              "${(item.urlSource == "web" || item.urlSource == "Web") ? '${webUrl}Sessions/Documents/${item.documentUrl}' : '${baseUrl0}Sessions/Documents/${item.documentUrl}'}";
          print("-------------------DocumentUrl=$docUrl");
          await launchUrl(Uri.parse(docUrl),
              mode: LaunchMode.externalApplication);
        }
      },
      child: Card(
        //----------------------------------------------Card
        elevation: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: item.active
                      ? defaultColor.withOpacity(0.5)
                      : Colors.black38),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                item.type == "Video" || item.type == "Promo"
                    ? Stack(
                        children: [
                          getImage(
                            item,
                            align,
                            60.0,
                            60.0,
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.black26,
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/play.png",
                                      width: 25,
                                      height: 25,
                                    ),
                                    Text(
                                      getVideoDuration(item.duration),
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ]),
                            ),
                          ),
                        ],
                      )
                    : getImage(
                        item,
                        align,
                        60.0,
                        60.0,
                      ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: getTitle(widget.dir, widget.LessonName, item, 16.1)),
                Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: PopupMenuButton(
                      icon: Icon(Icons.more_horiz,
                          color: Colors.black54), // add this line
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                            item.type != "Quiz" && item.type != "Promo"
                                ? new PopupMenuItem<String>(
                                    child: Container(
                                        width: 150,
                                        // height: 30,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.blue.shade700,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              widget.dir == "ltr"
                                                  ? "Rename"
                                                  : "إعادة تسمية",
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        )),
                                    value: 'edit')
                                : null,
                            item.type == "Video" || item.type == "Promo"
                                ? new PopupMenuItem<String>(
                                    child: Container(
                                        width: 150,
                                        // height: 30,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: Colors.blue.shade700,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              widget.dir == "ltr"
                                                  ? "Video Thumbnail"
                                                  : "أيقونة الفيديو",
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        )),
                                    value: 'changeVideoThumbnail')
                                : null,
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 182,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: item.active == false
                                              ? Colors.red.shade700
                                              : Colors.black54,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.dir == "ltr"
                                              ? "Under Construction"
                                              : "قيد الإعداد",
                                          style: TextStyle(
                                              color: item.active == false
                                                  ? Colors.red.shade700
                                                  : Colors.black54),
                                        ),
                                      ],
                                    )),
                                value: 'setInactive'),
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 150,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye,
                                          color: item.active
                                              ? Colors.green.shade700
                                              : Colors.black54,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.dir == "ltr"
                                              ? "Ready to show"
                                              : "جاهز للعرض",
                                          style: TextStyle(
                                              color: item.active
                                                  ? Colors.green.shade700
                                                  : Colors.black54),
                                        ),
                                      ],
                                    )),
                                value: 'setActive'),
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 100,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red.shade700,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.dir == "ltr"
                                              ? "Delete"
                                              : "حذف",
                                          style:
                                              TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    )),
                                value: 'delete'),
                          ],
                      onSelected: (index) async {
                        switch (index) {
                          case 'delete': //--------------------------------------remove record
                            showDialog(
                                context: context,
                                builder: (ctx) => Directionality(
                                      textDirection: widget.dir == "ltr"
                                          ? TextDirection.ltr
                                          : TextDirection.rtl,
                                      child: AlertDialog(
                                        titleTextStyle: TextStyle(
                                            color: defaultColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        title: Text(widget.dir == "ltr"
                                            ? 'Are you sure?'
                                            : "هل انت متأكد؟"),
                                        content: Text(
                                          widget.dir == "ltr"
                                              ? 'Are you sure that you want to remove this record?'
                                              : "هل تريد حذف هذا السجل؟",
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(widget.dir == "ltr"
                                                ? "No"
                                                : "لا"),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(widget.dir == "ltr"
                                                ? 'Yes'
                                                : "نعم"),
                                            onPressed: () async {
                                              await Provider.of<
                                                          TeacherSessionProvider>(
                                                      context,
                                                      listen: false)
                                                  .DeleteSessionDetail(
                                                      context,
                                                      item.id,
                                                      widget.TeacherId);

                                              await Provider.of<
                                                          TeacherSessionProvider>(
                                                      context,
                                                      listen: false)
                                                  .getData(
                                                      context,
                                                      widget.TeacherId,
                                                      widget.LessonId);
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ));

                            break;
                          case 'edit':
                            RenameSessionDetail();
                            break;
                          case 'setInactive':
                            DeactivateSessionDetail();

                            break;
                          case 'setActive':
                            ActivateSessionDetail();
                            break;
                          case 'changeVideoThumbnail':
                            UploadVideoThumbnail();
                            break;
                          //-------------------------------------Edit Note
                        }
                      }),
                ),
              ]),
              SizedBox(
                height: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget getImage(
    TeacherSessionDetail sd, String align, double width, double height) {
  if (align == "left") {
    align = "right";
  } else {
    align = "left";
  }
  switch (sd.type) {
    case "Promo":
      return Image.network(
        //'assets/images/${sd.type}_left.png',
        '${sd.coverUrlSource == "web" || sd.coverUrlSource == "Web" ? webUrl : baseUrl0}Sessions/VideoCovers/${sd.videoCover}',
        width: 60,
        height: 60, fit: BoxFit.cover,
      );
      break;
    case "Video":
      return Image.network(
        '${sd.coverUrlSource == "web" || sd.coverUrlSource == "Web" ? webUrl : baseUrl0}Sessions/VideoCovers/${sd.videoCover}',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
      break;
    default:
      return Image.asset(
        'assets/images/${sd.type}_${align}${sd.active ? "" : "_disabled"}.png',
        width: width,
        height: height,
      );

      break;
  }
}

Widget getTitle(
    String dir, String LessonName, TeacherSessionDetail sd, double fontSize) {
  switch (sd.type) {
    case "Promo":
      return Text(sd.title,
          style: TextStyle(
              fontSize: fontSize,
              color: sd.active ? defaultColor : Colors.black38));
      break;
    case "Video":
      var title = sd.title;
      if (sd.title.trim() == LessonName.trim()) {
        title = dir == "ltr" ? "Video" : "فيديو";
      }

      return Text(title,
          style: TextStyle(
              fontSize: fontSize,
              color: sd.active ? defaultColor : Colors.black38));

      break;
    default:
      return Text(sd.title,
          style: TextStyle(
              fontSize: fontSize,
              color: sd.active ? defaultColor : Colors.black38));

      break;
  }
}

String getVideoDuration(dur) {
  final duration = Duration(milliseconds: dur * 1000);

  return [duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}

class EmptyContentWidget extends StatelessWidget {
  EmptyContentWidget(this.dir, {Key key}) : super(key: key);
  String dir;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Directionality(
          textDirection: dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/empty-content.png'),
              SizedBox(
                height: 5,
              ),
              Text(
                dir == "ltr"
                    ? "Click on the '+' button below to add a new content"
                    : "لإضافة محتوى جديد إضغط ايقونة '+'",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
