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
import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentLessonSessionsScreen extends StatefulWidget {
  final int studentId;
  final int lessonId;
  final String lessonName;
  final String lessonDescription;
  final int YearSubjectId;
  final String dir;

  StudentLessonSessionsScreen(this.studentId, this.lessonId, this.lessonName,
      this.lessonDescription, this.YearSubjectId, this.dir,
      {Key key})
      : super(key: key);

  @override
  var showLessons = false;
  State<StudentLessonSessionsScreen> createState() =>
      _StudentLessonSessionsScreenState();
}

class _StudentLessonSessionsScreenState
    extends State<StudentLessonSessionsScreen> {
  StudentLessonsByYearSubjectId_collection
      StudentLessonsByYearSubjectIdCollection;
  StudentLessonSessions StudentLessonSessionCollection;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  int currentLessonIndex = 0;
  @override
  void initState() {
    super.initState();
    getSessions(widget.studentId, widget.lessonId);
    getLessons(widget.studentId, widget.YearSubjectId, widget.lessonId);
  }

  void getSessions(Id, LessonId) {
    DioHelper.getData(
            url: 'StudentLessonSessions',
            query: {'Id': Id, 'LessonId': LessonId},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["data"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      setState(() {
        StudentLessonSessionCollection =
            StudentLessonSessions.fromJson(value.data["data"]);
      });
    }).catchError((error) {
      print(error.toString());
      showToast(
          text: lang == "en" ? "Unkown error occured!" : "حدث خطأ ما!",
          state: ToastStates.ERROR);
    });
  }

  void getLessons(Id, YearSubjectId, LessonId) {
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

      var i = 0;
      while (i < StudentLessonsByYearSubjectIdCollection.items.length) {
        if (StudentLessonsByYearSubjectIdCollection.items[i].id == LessonId) {
          setState(() {
            currentLessonIndex = i;
          });
        }
        i++;
      }
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
        appBar: appBarComponent(context, widget.lessonName),
        body: StudentLessonSessionCollection == null ||
                StudentLessonsByYearSubjectIdCollection == null
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  getSessions(widget.studentId, widget.lessonId);
                  getLessons(
                      widget.studentId, widget.YearSubjectId, widget.lessonId);
                },
                child: widget.showLessons == false
                    ?
                    //---------------------------------------------------------------- Teachers
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: 25,
                              margin: EdgeInsets.only(right: 7),
                              child: GestureDetector(
                                child: Image.asset(
                                  "assets/images/expand_right.png",
                                  width: 25,
                                  height: 50,
                                  opacity: AlwaysStoppedAnimation(1),
                                ),
                                onTap: () {
                                  setState(() {
                                    widget.showLessons = true;
                                    print(widget.showLessons);
                                  });
                                },
                              )),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: StudentLessonSessionCollection
                                        .items.length,
                                    itemBuilder: (context, index) {
                                      var item = StudentLessonSessionCollection
                                          .items[index];
                                      //-----------------------------------------------------------card
                                      return InkWell(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              StudentSessionDetailsScreen(
                                                SessionHeaderId: item.sessionId,
                                                LessonName: widget.lessonName,
                                                LessonDescription:
                                                    widget.lessonDescription,
                                                dir: widget.dir,
                                                StudentId: widget.studentId,
                                                TeacherName: item.teacherName,
                                              ));
                                        },
                                        child: Card(
                                          elevation: 5,
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                  //-------------------------------------------------card row
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 32,
                                                      backgroundColor: item
                                                              .isFree
                                                          ? Colors.black45
                                                          : item.isPurchased
                                                              ? Colors.green
                                                              : Colors
                                                                  .amber[700],
                                                      child: CircleAvatar(
                                                        //-----------------------------------------Avatar
                                                        radius: 30,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Stack(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                child: item.teacherPhoto ==
                                                                        null
                                                                    ? Image
                                                                        .asset(
                                                                        'assets/images/Teacher.jpg',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : Image
                                                                        .network(
                                                                        '${webUrl}images/Profiles/${item.teacherPhoto}',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                              ),
                                                              item.isFree ==
                                                                      false
                                                                  ? item
                                                                          .isPurchased
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/images/UnLock.png",
                                                                          width:
                                                                              25,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          "assets/images/Lock.png",
                                                                          width:
                                                                              25,
                                                                        )
                                                                  : Container()
                                                            ]),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        //------------------------------------Name & Rating
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item.teacherName,
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          RatingBarIndicator(
                                                            rating: double
                                                                .parse(item.rate
                                                                    .toStringAsFixed(
                                                                        2)),
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: 20.0,
                                                            direction:
                                                                Axis.horizontal,
                                                            itemPadding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        0),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                        //----------------------------------------Statistics
                                                        width: 50,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .video_collection,
                                                                    color: Colors
                                                                        .black45),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(item.videos
                                                                    .toString())
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.quiz,
                                                                    color: Colors
                                                                        .black45),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(item.quizes
                                                                    .toString())
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .remove_red_eye_rounded,
                                                                    color: Colors
                                                                        .black45),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(item
                                                                    .watches
                                                                    .toString())
                                                              ],
                                                            )
                                                          ],
                                                        ))
                                                  ]),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black87
                                                        .withOpacity(0.3),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    :
                    //-----------------------------------------------------------Lessons
                    Row(children: [
                        Container(
                            width: 25,
                            margin: EdgeInsets.only(right: 3),
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/images/expand_left.png",
                                width: 25,
                                height: 50,
                                opacity: AlwaysStoppedAnimation(1),
                              ),
                              onTap: () {
                                setState(() {
                                  widget.showLessons = false;
                                  print(widget.showLessons);
                                });
                              },
                            )),
                        Expanded(
                          child: Column(children: [
                            Expanded(
                                child: ScrollablePositionedList.builder(
                                    itemScrollController: _itemScrollController,
                                    initialScrollIndex: currentLessonIndex,
                                    itemCount:
                                        StudentLessonsByYearSubjectIdCollection
                                            .items.length,
                                    itemBuilder: (context, index) {
                                      var item =
                                          StudentLessonsByYearSubjectIdCollection
                                              .items[index];
                                      return InkWell(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              StudentLessonSessionsScreen(
                                                  widget.studentId,
                                                  item.id,
                                                  item.lessonName,
                                                  item.lessonDescription,
                                                  widget.YearSubjectId,
                                                  widget.dir));
                                        },
                                        child: Container(
                                          //-----------------------------------------item Container
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: index == currentLessonIndex
                                                  ? defaultColor.withOpacity(.7)
                                                  : Colors.white,
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.black54),
                                                  right: BorderSide(
                                                      color: Colors.black54),
                                                  top: BorderSide(
                                                      color: Colors.black54))),
                                          child: Directionality(
                                            textDirection: item.dir == "ltr"
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            child: Row(
                                              //-----------------------------------------item row
                                              children: [
                                                SizedBox(
                                                  width: item.parentLessonId !=
                                                          null
                                                      ? 15
                                                      : 3,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.lessonName,
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: item
                                                                        .parentLessonId ==
                                                                    null
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                            color: index ==
                                                                    currentLessonIndex
                                                                ? Colors.white
                                                                : Colors
                                                                    .black54),
                                                      ),
                                                      item.dataDate != null
                                                          ? Container(
                                                              width: double
                                                                  .infinity,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              child: Text(
                                                                intl.DateFormat(
                                                                        "EEE d-MMM")
                                                                    .format(item
                                                                        .dataDate)
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    color: index ==
                                                                            currentLessonIndex
                                                                        ? Colors
                                                                            .white54
                                                                        : Colors
                                                                            .black26),
                                                              ),
                                                            )
                                                          : Container(),
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
                        ),
                        SizedBox(
                          width: 5,
                        )
                      ]),
              ));
  }
}
