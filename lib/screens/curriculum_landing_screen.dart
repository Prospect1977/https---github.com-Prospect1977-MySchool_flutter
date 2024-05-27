import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:my_school/models/SchoolTypeYearOfStudy.dart';
import 'package:my_school/models/StudentSubject.dart';
import 'package:my_school/screens/curriculum_Edit_screen.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen1.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class CurriculumLandingScreen extends StatefulWidget {
  const CurriculumLandingScreen({Key key}) : super(key: key);

  @override
  State<CurriculumLandingScreen> createState() =>
      _CurriculumLandingScreenState();
}

class _CurriculumLandingScreenState extends State<CurriculumLandingScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  var token = CacheHelper.getData(key: 'token');
  SchoolTypes schoolTypes = null;
  YearsOfStudies yearsOfStudies = null;
  List<DropdownMenuItem> SchoolTypesItems = [];
  List<DropdownMenuItem> YearsOfStudiesItems = [];
  List<DropdownMenuItem> Terms = [];
  List<DropdownMenuItem> YearSubjects = [];
  List<YearOfStudy> FilterdYearsOfStudies = null;
  TeacherSubjects subjects;
  String SelectedSubjectDir;
  int Form_SchoolTypeId = 0;
  int Form_TermIndex = 0;
  int Form_YearOfStudyId = 0;
  int Form_YearSubjectId = 0;
  bool showNonAuthorizedWidget = false;
  String nonAuthorizedMessage = "";
  String phoneNumber;
  bool isLoadingYearsOfStudy = false;
  bool isLoadingSubjects = false;
  void getData() {
    DioHelper.getData(
            url: 'Lessons',
            query: {"UserId": CacheHelper.getData(key: 'userId')},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        setState(() {
          showNonAuthorizedWidget = true;
          setState(() {
            nonAuthorizedMessage = value.data["message"];
            phoneNumber = value.data["data"];
          });
        });
        return;
      }
      setState(() {
        print(value.data["data"]);
        schoolTypes = SchoolTypes.fromJson(value.data["data"]);
        SchoolTypesItems = schoolTypes.Items.map((t) => DropdownMenuItem(
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

  void StudyYearsBySchoolTypeId(id) async {
    setState(() {
      isLoadingYearsOfStudy = true;
    });
    await DioHelper.getData(
            url: 'Lessons/YearsOfStudyByStudyType',
            query: {"id": id},
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
        print(value.data["data"]);
        yearsOfStudies = YearsOfStudies.fromJson(value.data["data"]);
        YearsOfStudiesItems = yearsOfStudies.Items.map((y) => DropdownMenuItem(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white))),
                alignment:
                    lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  lang == "ar" ? y.YearOfStudyAra : y.YearOfStudyEng,
                ),
              ),
              value: y.YearOfStudyId,
            )).toList();
        isLoadingYearsOfStudy = false;
      });
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void GetYearSubjects() async {
    setState(() {
      isLoadingSubjects = true;
    });
    await DioHelper.getData(
            url: 'Lessons/SubjectsBySchoolTypeAndYear',
            query: {
              "SchoolTypeId": Form_SchoolTypeId,
              "YearOfStudyId": Form_YearOfStudyId,
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
        print(value.data["data"]);
        subjects = TeacherSubjects.fromJson(value.data["data"]);

        YearSubjects = subjects.Subjects.map((s) => DropdownMenuItem(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white))),
                alignment: s.dir == "ltr"
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(s.SubjectName),
              ),
              value: s.YearSubjectId,
            )).toList();
        isLoadingSubjects = false;
      });
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getTermsIndecies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Select Curriculum" : "إختر المنهج"),
      body: showNonAuthorizedWidget
          ? NotAuthorizedWidget(nonAuthorizedMessage, phoneNumber, lang)
          : schoolTypes == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: EdgeInsets.all(8),
                  child: Directionality(
                    textDirection:
                        lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
                    child: Column(
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
                              iconEnabledColor: Colors.black54, //Icon color
                              style: TextStyle(
                                  //te
                                  color: Colors.black87, //Font color
                                  fontSize: 16 //font size on dropdown button
                                  ),
                              underline: Container(),

                              dropdownColor:
                                  Colors.white, //dropdown background color
                              //remove underline
                              isExpanded: true, //make true to make width 100%
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        isLoadingYearsOfStudy
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
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
                                  iconEnabledColor: Colors.black54, //Icon color
                                  style: TextStyle(
                                      //te
                                      color: Colors.black87, //Font color
                                      fontSize:
                                          16 //font size on dropdown button
                                      ),
                                  underline: Container(),

                                  dropdownColor:
                                      Colors.white, //dropdown background color
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
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black38),
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
                                                    color: Colors.white))),
                                        alignment: lang == "en"
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          lang == "en" ? "Subject" : "المادة",
                                        ),
                                      ),
                                      value: 0,
                                    ),
                                    ...YearSubjects,
                                  ],

                                  onChanged: (value) {
                                    setState(() {
                                      Form_YearSubjectId = value;
                                      SelectedSubjectDir =
                                          subjects.Subjects.firstWhere(
                                              (element) =>
                                                  element.YearSubjectId ==
                                                  value).dir;
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
                                      fontSize:
                                          16 //font size on dropdown button
                                      ),
                                  underline: Container(),

                                  dropdownColor:
                                      Colors.white, //dropdown background color
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
                                      lang == "en" ? "Term" : "الفصل الدراسي",
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
                              iconEnabledColor: Colors.black54, //Icon color
                              style: TextStyle(
                                  //te
                                  color: Colors.black87, //Font color
                                  fontSize: 16 //font size on dropdown button
                                  ),
                              underline: Container(),

                              dropdownColor:
                                  Colors.white, //dropdown background color
                              //remove underline
                              isExpanded: true, //make true to make width 100%
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (Form_SchoolTypeId > 0 &&
                                    Form_YearOfStudyId > 0 &&
                                    Form_TermIndex > 0 &&
                                    Form_YearSubjectId > 0) {
                                  // Navigator.of(context).pop();
                                  navigateTo(
                                      context,
                                      CurriculumEditScreen(
                                        TermIndex: Form_TermIndex,
                                        YearSubjectId: Form_YearSubjectId,
                                        dir: SelectedSubjectDir,
                                      ));
                                }
                              },
                              child: Text(lang == "en" ? "Go" : "موافق"),
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
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(lang == "en" ? "Cancel" : "إلغاء"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black26,
                                  foregroundColor: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}

class NotAuthorizedWidget extends StatelessWidget {
  NotAuthorizedWidget(this.message, this.phoneNumber, this.lang, {Key key})
      : super(key: key);
  String message;
  String phoneNumber;
  String lang;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Directionality(
        textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/not-authorized.jpg"),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              SizedBox(
                height: 15,
              ),
              IconButton(
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
                  },
                  icon: Image.asset(
                    'assets/images/phone.png',
                  ),
                  iconSize: 50),
            ],
          ),
        ),
      ),
    );
  }
}
