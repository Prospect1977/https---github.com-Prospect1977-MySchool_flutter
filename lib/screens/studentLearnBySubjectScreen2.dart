import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:my_school/cubits/StudentLessonSessions_cubit.dart';
import 'package:my_school/cubits/StudentLessonSessions_states.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentLessonSessions_screen.dart';
import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/screens/teacher_profile_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/studentStudyBySubject_navigation_bar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentLearnBySubjectScreen2 extends StatefulWidget {
  final int studentId;

  final int YearSubjectId;
  final String SubjectName;
  final String dir;

  StudentLearnBySubjectScreen2(
      {this.studentId, this.YearSubjectId, this.dir, this.SubjectName, Key key})
      : super(key: key);

  @override
  State<StudentLearnBySubjectScreen2> createState() => _StudentLessonState();
}

class _StudentLessonState extends State<StudentLearnBySubjectScreen2> {
  StudentLessonsByYearSubjectId_collection
      StudentLessonsByYearSubjectIdCollection;

  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");

  @override
  void initState() {
    super.initState();
    getLessons(widget.studentId, widget.YearSubjectId);
  }

  void getLessons(Id, YearSubjectId) {
    setState(() {
      StudentLessonsByYearSubjectIdCollection = null;
    });

    DioHelper.getData(
            url: 'LessonsByYearSubjectId',
            query: {'Id': Id, 'YearSubjectId': YearSubjectId},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      setState(() {
        StudentLessonsByYearSubjectIdCollection =
            StudentLessonsByYearSubjectId_collection.fromJson(
                value.data["data"]);
      });
    }).catchError((error) {
      print(error.toString());
      showToast(
          text: lang == "en" ? "Unkown error occured!" : "حدث خطأ ما!",
          state: ToastStates.ERROR);
    });
  }

  final ItemScrollController _itemScrollController = ItemScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, widget.SubjectName),
        bottomNavigationBar: StudentStudyBySubjectNavigationBar(
            PageIndex: 0, StudentId: widget.studentId),
        body: StudentLessonsByYearSubjectIdCollection == null
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  getLessons(widget.studentId, widget.YearSubjectId);
                },
                child: Column(children: [
                  Expanded(
                      child: ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          itemCount: StudentLessonsByYearSubjectIdCollection
                              .items.length,
                          itemBuilder: (context, index) {
                            var item = StudentLessonsByYearSubjectIdCollection
                                .items[index];
                            return InkWell(
                              onTap: () {
                                if (!item.blockedFromAddingSessions) {
                                  navigateTo(
                                      context,
                                      StudentLessonSessionsScreen(
                                          widget.studentId,
                                          item.id,
                                          item.lessonName,
                                          item.lessonDescription,
                                          widget.YearSubjectId,
                                          widget.dir));
                                } else {
                                  showToast(
                                      text: item.dir == "ltr"
                                          ? "Main chapters have no content!"
                                          : "الأبواب الرئيسية ليس لها محتوى",
                                      state: ToastStates.ERROR);
                                }
                              },
                              child: Container(
                                //-----------------------------------------item Container
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        top: BorderSide(
                                            width: 0.25, color: defaultColor),
                                        bottom: index ==
                                                StudentLessonsByYearSubjectIdCollection
                                                        .items.length -
                                                    1
                                            ? BorderSide(color: Colors.black38)
                                            : BorderSide(
                                                color: defaultColor,
                                                width: 0.25))),
                                child: Directionality(
                                  textDirection: item.dir == "ltr"
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  child: Row(
                                    //-----------------------------------------item row
                                    children: [
                                      SizedBox(
                                        width: item.parentLessonId != null
                                            ? 15
                                            : 3,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.lessonName,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight:
                                                    item.parentLessonId == null
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color: defaultColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            item.dataDate != null
                                                ? Container(
                                                    width: double.infinity,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          size: 18,
                                                          color: Colors.black54,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          formatDate(
                                                            item.dataDate,
                                                            item.dir == "ltr"
                                                                ? "en"
                                                                : "ar",
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            item.lessonProgress > 0
                                                ? SizedBox(
                                                    height: 5,
                                                  )
                                                : Container(),
                                            item.lessonProgress > 0
                                                ? Directionality(
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    child: Container(
                                                      height: 3,
                                                      child: Stack(children: [
                                                        FractionallySizedBox(
                                                          widthFactor:
                                                              item.lessonProgress >=
                                                                      100
                                                                  ? 1
                                                                  : item.lessonProgress /
                                                                      100,
                                                          heightFactor: 1,
                                                          child: Container(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                        Container(
                                                          color: Colors.black26,
                                                        )
                                                      ]),
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }))
                ]),
              ));
  }
}
