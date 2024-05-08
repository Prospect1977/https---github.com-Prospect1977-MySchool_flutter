import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/teacher_lesson.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/teacher_session_screen.dart';
import 'package:my_school/screens/ticket_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class TeacherSubjectAllLessons extends StatefulWidget {
  int TeacherId;
  int YearSubjectId;
  int TermIndex;
  TeacherSubjectAllLessons(
      {@required this.TeacherId,
      @required this.YearSubjectId,
      @required this.TermIndex,
      Key key})
      : super(key: key);

  @override
  State<TeacherSubjectAllLessons> createState() =>
      _TeacherSubjectAllLessonsState();
}

class _TeacherSubjectAllLessonsState extends State<TeacherSubjectAllLessons> {
  String SubjectName = "";
  String dir = "";
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");

  TeacherLessons teacherLessons = null;
  void getData() {
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
      print(value.data["data"]);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        teacherLessons = TeacherLessons.fromJson(value.data["data"]);
        SubjectName = value.data["additionalData"]["subjectName"];
        dir = value.data["additionalData"]["dir"];
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, SubjectName),
        body: teacherLessons == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(8),
                child: teacherLessons.Lessons.length == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo.png'),
                            Text(
                              lang == "ar"
                                  ? "لم يتم بعد إضافة دروس المنهج من قبل إدارة التطبيق"
                                  : "No lesson has been added yet by the app. administration!",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            defaultButton(
                                function: () {
                                  Navigator.of(context).pop();
                                  navigateTo(context, TicketScreen());
                                },
                                text:
                                    lang == "ar" ? "تواصل معنا" : "Contact Us"),
                          ],
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) {
                          var item = teacherLessons.Lessons[index];
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
                        itemCount: teacherLessons.Lessons.length,
                        itemBuilder: (context, index) {
                          var item = teacherLessons.Lessons[index];
                          return InkWell(
                            onTap: item.blockedFromAddingSessions
                                ? () {
                                    showToast(
                                        text: dir == "ltr"
                                            ? "There is no content for main units!"
                                            : "لا يوجد محتوى للأبواب الرئيسية!",
                                        state: ToastStates.ERROR);
                                  }
                                : () {
                                    navigateTo(
                                        context,
                                        TeacherSessionScreen(
                                            TeacherId: widget.TeacherId,
                                            YearSubjectId: widget.YearSubjectId,
                                            TermIndex: widget.TermIndex,
                                            LessonId: item.id,
                                            LessonName: item.lessonName,
                                            dir: dir));
                                  },
                            child: Directionality(
                              textDirection: dir == "ltr"
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
                                            color: teacherLessons.Lessons.where(
                                                        (m) =>
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
                                                  color: teacherLessons.Lessons.where((m) =>
                                                              m.parentLessonId ==
                                                              item.id).length >
                                                          0
                                                      ? Colors.white
                                                      : defaultColor
                                                          .withAlpha(200),
                                                  fontStyle:
                                                      item.parentLessonId == null
                                                          ? FontStyle.normal
                                                          : FontStyle.italic,
                                                  fontSize:
                                                      item.parentLessonId == null
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
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_month,
                                                          size: 15,
                                                          color: Colors.black54,
                                                        ),
                                                        if (item.dataDate !=
                                                            null)
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                        if (item.dataDate !=
                                                            null)
                                                          Text(
                                                              formatDate(
                                                                  DateTime.parse(item
                                                                      .dataDate),
                                                                  dir == "ltr"
                                                                      ? "en"
                                                                      : "ar"),
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.video_collection,
                                                      size: 18,
                                                      color: item.videos > 0
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors.black26,
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(
                                                      item.videos.toString(),
                                                      style: TextStyle(
                                                        color: item.videos > 0
                                                            ? Colors
                                                                .green.shade800
                                                            : Colors.black26,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.quiz,
                                                      size: 18,
                                                      color: item.quizzes > 0
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors.black26,
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(
                                                      item.quizzes.toString(),
                                                      style: TextStyle(
                                                        color: item.quizzes > 0
                                                            ? Colors
                                                                .green.shade800
                                                            : Colors.black26,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.file_copy,
                                                      size: 18,
                                                      color: item.documents > 0
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors.black26,
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(
                                                      item.documents.toString(),
                                                      style: TextStyle(
                                                        color: item.documents >
                                                                0
                                                            ? Colors
                                                                .green.shade800
                                                            : Colors.black26,
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
              ));
  }
}
