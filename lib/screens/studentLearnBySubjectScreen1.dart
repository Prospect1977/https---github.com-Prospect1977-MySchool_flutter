import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentSelectedSubject_states.dart';
import 'package:my_school/cubits/StudentSelectedSubjects_cubit.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/studentLearnBySubjectScreen2.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../models/StudentSubject.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class StudentLearnBySubjectScreen1 extends StatefulWidget {
  final int Id;
  const StudentLearnBySubjectScreen1(this.Id);

  @override
  State<StudentLearnBySubjectScreen1> createState() =>
      _StudentLearnBySubjectScreen1State();
}

class _StudentLearnBySubjectScreen1State
    extends State<StudentLearnBySubjectScreen1> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
    return Scaffold(
      appBar: appBarComponent(
        context,
        lang == "En" ? "Select Subject" : "إختر المادة",
        /*backButtonPage: CacheHelper.getData(key: "roles") == "Student"
              ? StudentDashboardScreen()
              : StudentDashboardScreen(Id: widget.Id)*/
      ),
      body: SubjectsList(widget.Id),
    );
  }
}

class SubjectsList extends StatefulWidget {
  final int Id;
  const SubjectsList(this.Id);

  @override
  State<SubjectsList> createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  @override
  var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
  var StudentSubjectsList;

  void getSubjectsList() async {
    var token = CacheHelper.getData(key: 'token');
    var lang = CacheHelper.getData(key: 'lang');
    DioHelper.getData(
      lang: lang,
      query: {"Id": widget.Id},
      token: token,
      url: "StudentSelectedSubjects",
    ).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
      }
      if (value.data["status"] == false) {
        CacheHelper.removeData(key: "userId");
        CacheHelper.removeData(key: "token");
        CacheHelper.removeData(key: "roles");
        return;
      }
      print(value.data['data']);
      setState(() {
        StudentSubjectsList = jsonDecode(value.data['data'])
            .map((s) => StudentSubject.fromJson(s))
            .toList();
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubjectsList();
  }

  Widget build(BuildContext context) {
    return StudentSubjectsList != null
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: StudentSubjectsList.length,
                    itemBuilder: ((context, index) {
                      var item = StudentSubjectsList[index];

                      return item.Checked == false
                          ? Container()
                          : Container(
                              child: InkWell(
                                onTap: () {
                                  CacheHelper.saveData(
                                      key: "yearSubjectId",
                                      value: item.YearSubjectId);
                                  CacheHelper.saveData(
                                      key: "subjectName",
                                      value: item.SubjectName);
                                  CacheHelper.saveData(
                                      key: "dir", value: item.dir);
                                  navigateTo(
                                      context,
                                      StudentLearnBySubjectScreen2(
                                        YearSubjectId: item.YearSubjectId,
                                        dir: item.dir,
                                        studentId: widget.Id,
                                        SubjectName: item.SubjectName,
                                      ));
                                },
                                child: Container(
                                  child: Card(
                                      elevation: 0,
                                      child: Directionality(
                                        textDirection: item.dir == "ltr"
                                            ? TextDirection.ltr
                                            : TextDirection.rtl,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: defaultColor
                                                        .withOpacity(0.3)),
                                                color: Colors.white),
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                item.ParentId != null
                                                    ? SizedBox(
                                                        width: 20,
                                                      )
                                                    : Container(),
                                                Expanded(
                                                  child: Text(
                                                    item.SubjectName,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: defaultColor,
                                                        fontWeight: item
                                                                    .ParentId ==
                                                                null
                                                            ? FontWeight.bold
                                                            : FontWeight
                                                                .normal),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      )),
                                ),
                              ),
                            );
                    })),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Widget SubjectsList(StudentSelectedSubjectsCubit cubit) {
  
// }
