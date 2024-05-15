import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentSelectedSubject_states.dart';
import 'package:my_school/cubits/StudentSelectedSubjects_cubit.dart';
import 'package:my_school/models/StudentSubject.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class StudentSelectedSubjectsScreen extends StatefulWidget {
  final int Id;
  const StudentSelectedSubjectsScreen(this.Id);

  @override
  State<StudentSelectedSubjectsScreen> createState() =>
      _StudentSelectedSubjectsScreenState();
}

class _StudentSelectedSubjectsScreenState
    extends State<StudentSelectedSubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
    return Scaffold(
      appBar: appBarComponent(
        context,
        lang == "en" ? "Available Subjects" : "المواد المتاحة",
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
        for (var i = 0; i < StudentSubjectsList.length; i++) {
          if (StudentSubjectsList[i].Checked) {
            _selectedItems.add(StudentSubjectsList[i].SubjectId);
          }
        }
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void saveSubjectsList(context, List<int> SubjectsList) async {
    // emit(LoadingState());

    var token = CacheHelper.getData(key: 'token');
    var lang = CacheHelper.getData(key: 'lang');
    DioHelper.postData(
      lang: lang,
      data: {"selectedYearsSubjectIds": SubjectsList},
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
        navigateAndFinish(context, LoginScreen());
      }
      print(value.data['data']);
      showToast(
          text: lang == "en"
              ? "Selected subjects saved successfully!"
              : "تم حفظ المواد المختارة بنجاح!",
          state: ToastStates.SUCCESS);
      Navigator.of(context).pop();
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

  @override
  List<int> _selectedItems = [];
  bool _isChanged = false;
  var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
  //bool _isCurrentItemSelected = false;
  Widget build(BuildContext context) {
    return StudentSubjectsList != null
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: StudentSubjectsList.length,
                    itemBuilder: ((context, index) {
                      var item = StudentSubjectsList[index];

                      return Container(
                        child: InkWell(
                          onTap: () {
                            if (!_selectedItems.contains(item.SubjectId)) {
                              setState(() {
                                _selectedItems.add(item.SubjectId);
                                _isChanged = true;
                                if (item.ParentId != null) {
                                  if (!_selectedItems.contains(item.ParentId)) {
                                    _selectedItems.add(item.ParentId);
                                  }
                                } else {
                                  if (StudentSubjectsList.where((m) =>
                                          m.ParentId == item.SubjectId).length >
                                      0) {
                                    StudentSubjectsList.where(
                                            (m) => m.ParentId == item.SubjectId)
                                        .forEach((item) {
                                      _selectedItems.add(item.SubjectId);
                                    });
                                  }
                                }
                              });
                            } else {
                              setState(() {
                                _selectedItems.removeWhere(
                                    (SId) => SId == item.SubjectId);
                                _isChanged = true;
                                var itemsBelongToSameParent =
                                    StudentSubjectsList.where((element) =>
                                            element.ParentId == item.ParentId)
                                        .toList();
                                int CountSelectedItemsToTheSameParent = 0;
                                itemsBelongToSameParent.forEach((m) {
                                  if (_selectedItems
                                          .where((element) =>
                                              element == m.SubjectId)
                                          .length ==
                                      1) {
                                    CountSelectedItemsToTheSameParent += 1;
                                  }
                                });
                                if (item.ParentId != null &&
                                    CountSelectedItemsToTheSameParent == 0) {
                                  _selectedItems.remove(item.ParentId);
                                }
                                if (item.ParentId == null) {
                                  StudentSubjectsList.where((element) =>
                                          element.ParentId == item.SubjectId)
                                      .forEach((element) {
                                    _selectedItems.remove(element.SubjectId);
                                  });
                                }
                              });
                            }
                            print(_selectedItems);
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
                                                  fontWeight:
                                                      item.ParentId == null
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                          ),
                                          _selectedItems
                                                  .contains(item.SubjectId)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                )
                                              : Container()
                                        ],
                                      )),
                                )),
                          ),
                        ),
                      );
                    })),
              ),
              defaultButton(
                  function: _isChanged
                      ? () {
                          saveSubjectsList(context, _selectedItems);
                          setState(() {
                            _isChanged = false;
                          });
                        }
                      : null,
                  borderRadius: 0,
                  text: lang == "en" ? "Save Changes" : "حفظ التعديلات",
                  background:
                      _isChanged ? Colors.green.shade700 : Colors.black54),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Widget SubjectsList(StudentSelectedSubjectsCubit cubit) {
  
// }
