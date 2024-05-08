import 'package:flutter/material.dart';

import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentLessonSessions_screen.dart';

import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

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
  int TermIndex = 0;
  int TermsCount = 0;
  List<DropdownMenuItem> Terms = [];
  void getTermsIndecies() {
    Terms = [
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            widget.dir == "ltr" ? '1st Term' : 'الفصل الدراسي الأول',
          ),
        ),
        value: 1,
      ),
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            widget.dir == "ltr" ? '2nd Term' : 'الفصل الدراسي الثاني',
          ),
        ),
        value: 2,
      ),
      if (TermsCount > 2)
        DropdownMenuItem(
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white))),
            alignment: widget.dir == "ltr"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.dir == "ltr" ? '3rd Term' : 'الفصل الدراسي الثالث',
            ),
          ),
          value: 3,
        ),
      if (TermsCount > 3)
        DropdownMenuItem(
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white))),
            alignment: widget.dir == "ltr"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.dir == "ltr" ? '4th Term' : 'الفصل الدراسي الرابع',
            ),
          ),
          value: 4,
        ),
      if (TermsCount > 4)
        DropdownMenuItem(
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white))),
            alignment: widget.dir == "ltr"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.dir == "ltr" ? '5th Term' : 'الفصل الدراسي الخامس',
            ),
          ),
          value: 5,
        ),
      if (TermsCount > 5)
        DropdownMenuItem(
          child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white))),
            alignment: widget.dir == "ltr"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.dir == "ltr" ? '6th Term' : 'الفصل الدراسي السادس',
            ),
          ),
          value: 6,
        ),
    ];
  }

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
            query: {
              'Id': Id,
              'YearSubjectId': YearSubjectId,
              'TermIndex': TermIndex
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        StudentLessonsByYearSubjectIdCollection =
            StudentLessonsByYearSubjectId_collection.fromJson(
                value.data["data"]);
        TermsCount = value.data["additionalData"];
        getTermsIndecies();
      });
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black26)),
                    child: DropdownButton(
                      //key: ValueKey(1),
                      value: TermIndex,
                      items: [
                        //add items in the dropdown
                        DropdownMenuItem(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.white))),
                            alignment: widget.dir == "ltr"
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Text(
                              widget.dir == "ltr"
                                  ? "Current Term"
                                  : "الفصل الدراسي الحالي",
                            ),
                          ),
                          value: 0,
                        ),
                        ...Terms,
                      ],

                      onChanged: (value) {
                        setState(() {
                          TermIndex = value;
                        });
                        getLessons(widget.studentId, widget.YearSubjectId);
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
                    ),
                  ),
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
                                          TermIndex,
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
