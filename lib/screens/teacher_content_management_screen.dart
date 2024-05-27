import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/SchoolTypeYearOfStudy.dart';
import 'package:my_school/models/StudentSubject.dart';
import 'package:my_school/models/recentTeacherSessions.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/screens/teacher_session_screen.dart';
import 'package:my_school/screens/teacher_subject_allLessons.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../shared/components/functions.dart';

class TeacherContentManagementScreen extends StatefulWidget {
  int TeacherId;
  TeacherContentManagementScreen(this.TeacherId, {Key key}) : super(key: key);

  @override
  State<TeacherContentManagementScreen> createState() =>
      _TeacherContentManagementScreenState();
}

class _TeacherContentManagementScreenState
    extends State<TeacherContentManagementScreen> {
  String token = CacheHelper.getData(key: "token");
  String lang = CacheHelper.getData(key: "lang");
  RecentTeacherSessions recentSessions = null;
  SchoolTypesAndYearsOfStudies schoolTypesAndYearsOfStudies = null;
  bool newSessionFormVisible = false;
  List<DropdownMenuItem> SchoolTypesItems = [];
  List<DropdownMenuItem> YearsOfStudiesItems = [];
  List<DropdownMenuItem> Terms = [];
  List<DropdownMenuItem> YearSubjects = [];
  List<YearOfStudy> FilterdYearsOfStudies = null;
  int Form_SchoolTypeId = 0;
  int Form_TermIndex = 0;
  int Form_YearOfStudyId = 0;
  int Form_YearSubjectId = 0;
  bool isLoadingSubjects = false;

  void StudyYearsBySchoolTypeId(int SchoolTypeId) {
    setState(() {
      FilterdYearsOfStudies = [...schoolTypesAndYearsOfStudies.YearsOfStudies]
          .where((e) => e.SchoolTypeId == SchoolTypeId)
          .toList();
      YearsOfStudiesItems = SchoolTypeId == 0
          ? []
          : FilterdYearsOfStudies.map((y) => DropdownMenuItem(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white))),
                  alignment: lang == "en"
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Text(
                    lang == "en" ? y.YearOfStudyEng : y.YearOfStudyAra,
                  ),
                ),
                value: y.YearOfStudyId,
              )).toList();
    });
  }

  void GetYearSubjects() async {
    if (Form_SchoolTypeId > 0 && Form_YearOfStudyId > 0) {
      setState(() {
        isLoadingSubjects = true;
      });
      await DioHelper.getData(
          url: "TeacherContentManager/TeacherSubjectsByYearOfStudy",
          lang: lang,
          token: token,
          query: {
            "TeacherId": widget.TeacherId,
            "SchoolTypeId": Form_SchoolTypeId,
            "YearOfStudyId": Form_YearOfStudyId
          }).then((value) {
        print(value.data["data"]);
        if (value.data["status"] == false &&
            value.data["message"] == "SessionExpired") {
          handleSessionExpired(context);
          return;
        } else if (value.data["status"] == false) {
          showToast(text: value.data["message"], state: ToastStates.ERROR);
          return;
        }
        var SubjectsList = TeacherSubjects.fromJson(value.data["data"]);
        setState(() {
          YearSubjects = SubjectsList.Subjects.map((y) => DropdownMenuItem(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white))),
                  alignment: lang == "en"
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Directionality(
                    textDirection:
                        y.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
                    child: Row(
                      children: [
                        y.ParentId != null
                            ? SizedBox(
                                width: 15,
                              )
                            : Container(),
                        Text(
                          y.SubjectName,
                          style: TextStyle(
                              fontWeight: y.ParentId != null
                                  ? FontWeight.normal
                                  : FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                value: y.YearSubjectId,
              )).toList();
          isLoadingSubjects = false;
        });
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
      });
    }
  }

  void getData() {
    DioHelper.getData(
            url: 'TeacherContentManager',
            query: {'TeacherId': widget.TeacherId},
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
        recentSessions = RecentTeacherSessions.fromJson(
            value.data["data"]["recentTeacherSessions"]);
        schoolTypesAndYearsOfStudies = SchoolTypesAndYearsOfStudies.fromJson(
            value.data["data"]["schoolTypesAndYearsOfStudies"]);
        SchoolTypesItems = schoolTypesAndYearsOfStudies.SchoolTypes.map((t) =>
            DropdownMenuItem(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white))),
                alignment:
                    lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  lang == "en" ? t.NameEng : t.NameAra,
                ),
              ),
              value: t.Id,
            )).toList();
      });
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void getTermsIndecies() {
    Terms = [
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment:
              lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            lang == "en" ? '1st Term' : 'الفصل الدراسي الأول',
          ),
        ),
        value: 1,
      ),
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment:
              lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            lang == "en" ? '2nd Term' : 'الفصل الدراسي الثاني',
          ),
        ),
        value: 2,
      ),
    ];
  }

  void _checkAppVersion() async {
    await checkAppVersion();
    bool isUpdated = CacheHelper.getData(key: "isLatestVersion");
    if (isUpdated == false) {
      navigateTo(context, RequireUpdateScreen());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAppVersion();
    getData();
    getTermsIndecies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(
            context, lang == "en" ? "Content Manager" : "إدارة المحتوى"),
        body: schoolTypesAndYearsOfStudies == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    newSessionFormVisible == false
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                newSessionFormVisible = true;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.green.shade700)),
                              child: Text(
                                lang == "ar"
                                    ? "إضافة محتوى جديد"
                                    : "Add a new content",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          )
                        : //-------------------------------- New Sessions form
                        Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: DropdownButton(
                                    //key: ValueKey(1),
                                    value: Form_SchoolTypeId,
                                    items: [
                                      DropdownMenuItem(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white))),
                                          alignment: lang == "en"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Text(
                                            lang == "en"
                                                ? "Type of Study"
                                                : "نوعية التعليم",
                                          ),
                                        ),
                                        value: 0,
                                      ),
                                      ...SchoolTypesItems,
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        Form_SchoolTypeId = value;
                                        Form_YearOfStudyId = 0;
                                        StudyYearsBySchoolTypeId(value);
                                        Form_YearSubjectId = 0;
                                        // dirty = true;
                                        // widget.SchoolTypeName
                                      });
                                    },
                                    icon: Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.keyboard_arrow_down)),
                                    iconEnabledColor:
                                        Colors.black54, //Icon color
                                    style: TextStyle(
                                        //te
                                        color: Colors.black87, //Font color
                                        fontSize:
                                            16 //font size on dropdown button
                                        ),
                                    underline: Container(),

                                    dropdownColor: Colors
                                        .white, //dropdown background color
                                    //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: DropdownButton(
                                    //key: ValueKey(1),
                                    value: Form_YearOfStudyId,
                                    items: [
                                      //add items in the dropdown
                                      DropdownMenuItem(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white))),
                                          alignment: lang == "en"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Text(
                                            lang == "en"
                                                ? "Year of Study"
                                                : "السنة الدراسية",
                                          ),
                                        ),
                                        value: 0,
                                      ),
                                      ...YearsOfStudiesItems,
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        Form_YearOfStudyId = value;
                                        Form_YearSubjectId = 0;
                                        GetYearSubjects();
                                      });
                                    },
                                    icon: Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.keyboard_arrow_down)),
                                    iconEnabledColor:
                                        Colors.black54, //Icon color
                                    style: TextStyle(
                                        //te
                                        color: Colors.black87, //Font color
                                        fontSize:
                                            16 //font size on dropdown button
                                        ),
                                    underline: Container(),

                                    dropdownColor: Colors
                                        .white, //dropdown background color
                                    //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              isLoadingSubjects
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border:
                                            Border.all(color: Colors.black38),
                                      ),
                                      child: DropdownButton(
                                        //key: ValueKey(1),
                                        value: Form_YearSubjectId,
                                        items: [
                                          //add items in the dropdown
                                          DropdownMenuItem(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color:
                                                              Colors.white))),
                                              alignment: lang == "en"
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              child: Text(
                                                lang == "en"
                                                    ? "Subject"
                                                    : "المادة",
                                              ),
                                            ),
                                            value: 0,
                                          ),
                                          ...YearSubjects,
                                        ],

                                        onChanged: (value) {
                                          setState(() {
                                            Form_YearSubjectId = value;
                                          });
                                        },
                                        icon: Padding(
                                            //Icon at tail, arrow bottom is default icon
                                            padding: EdgeInsets.all(0),
                                            child: Icon(
                                                Icons.keyboard_arrow_down)),
                                        iconEnabledColor:
                                            Colors.black54, //Icon color
                                        style: TextStyle(
                                            //te
                                            color: Colors.black87, //Font color
                                            fontSize:
                                                16 //font size on dropdown button
                                            ),
                                        underline: Container(),

                                        dropdownColor: Colors
                                            .white, //dropdown background color
                                        //remove underline
                                        isExpanded:
                                            true, //make true to make width 100%
                                      )),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: DropdownButton(
                                    //key: ValueKey(1),
                                    value: Form_TermIndex,
                                    items: [
                                      //add items in the dropdown
                                      DropdownMenuItem(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white))),
                                          alignment: lang == "en"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Text(
                                            lang == "en"
                                                ? "Term"
                                                : "الفصل الدراسي",
                                          ),
                                        ),
                                        value: 0,
                                      ),
                                      ...Terms,
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        Form_TermIndex = value;
                                      });
                                    },
                                    icon: Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.keyboard_arrow_down)),
                                    iconEnabledColor:
                                        Colors.black54, //Icon color
                                    style: TextStyle(
                                        //te
                                        color: Colors.black87, //Font color
                                        fontSize:
                                            16 //font size on dropdown button
                                        ),
                                    underline: Container(),

                                    dropdownColor: Colors
                                        .white, //dropdown background color
                                    //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              Divider(),
                              Directionality(
                                textDirection: lang == "en"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (Form_SchoolTypeId > 0 &&
                                            Form_YearOfStudyId > 0 &&
                                            Form_TermIndex > 0 &&
                                            Form_YearSubjectId > 0) {
                                          navigateTo(
                                              context,
                                              TeacherSubjectAllLessons(
                                                  TermIndex: Form_TermIndex,
                                                  TeacherId: widget.TeacherId,
                                                  YearSubjectId:
                                                      Form_YearSubjectId));
                                        }
                                      },
                                      child:
                                          Text(lang == "en" ? "Go" : "موافق"),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          newSessionFormVisible = false;
                                        });
                                      },
                                      child: Text(
                                          lang == "en" ? "Cancel" : "إلغاء"),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black26,
                                          foregroundColor: Colors.white),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                color: interfaceColor.withAlpha(100),
                                thickness: 1),
                            itemCount: recentSessions.Sessions.length,
                            itemBuilder: ((context, index) {
                              RecentTeacherSession item =
                                  recentSessions.Sessions[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    navigateTo(
                                        context,
                                        TeacherSessionScreen(
                                          TeacherId: widget.TeacherId,
                                          LessonId: item.lessonId,
                                          LessonName: item.lessonName,
                                          TermIndex: item.termIndex,
                                          YearSubjectId: item.yearSubjectId,
                                          dir: item.dir,
                                        ));
                                  },
                                  child: Directionality(
                                    textDirection: item.dir == "rtl"
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      item.subjectName,
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    ),
                                                    Container(
                                                      width: 15,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text("|"),
                                                    ),
                                                    Text(
                                                      item.dir == "rtl"
                                                          ? item.yearOfStudyAra
                                                          : item.yearOfStudyEng,
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    ),
                                                    SizedBox(
                                                      width: 7,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 9,
                                                              vertical:
                                                                  item.dir ==
                                                                          "rtl"
                                                                      ? 1
                                                                      : 3),
                                                      decoration: BoxDecoration(
                                                          color: interfaceColor
                                                              .withAlpha(200),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50)),
                                                      child: Text(
                                                        item.dir == "rtl"
                                                            ? " الترم ${item.termIndex}"
                                                            : "Term ${item.termIndex}",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                item.dir ==
                                                                        "rtl"
                                                                    ? 13
                                                                    : 14),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 0,
                                                    ),
                                                    Container(
                                                      width: 275,
                                                      child: Text(
                                                        item.lessonName,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 15),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Directionality(
                                            textDirection: item.dir == "ltr"
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            child: Container(
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
                                                              ? Colors.green
                                                                  .shade800
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
                                                          color: item.quizzes >
                                                                  0
                                                              ? Colors.green
                                                                  .shade800
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
                                                        color: item.documents >
                                                                0
                                                            ? Colors
                                                                .green.shade700
                                                            : Colors.black26,
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Text(
                                                        item.documents
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              item.documents > 0
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
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })))
                  ],
                ),
              ));
  }
}
