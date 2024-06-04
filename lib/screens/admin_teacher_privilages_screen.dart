import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../shared/components/constants.dart';
import '../shared/components/functions.dart';

class AdminTeacherPrivilagesScreen extends StatefulWidget {
  AdminTeacherPrivilagesScreen(this.TeacherId, {Key key}) : super(key: key);
  int TeacherId;
  @override
  State<AdminTeacherPrivilagesScreen> createState() =>
      _AdminTeacherPrivilagesScreenState();
}

class _AdminTeacherPrivilagesScreenState
    extends State<AdminTeacherPrivilagesScreen> {
  Teacher TeacherData;
  List<Subject> Subjects;
  List<Year> Years;
  bool showSaveButton = false;
  bool showSubjects = false;
  bool showYears = false;
  void _showSubjects(bool value) {
    setState(() {
      showSubjects = value;
      print(showSubjects);
    });
  }

  void _showYears(bool value) {
    setState(() {
      showYears = value;
    });
  }

  void _updateSelectedSubjects(List<Subject> newSubjects) {
    setState(() {
      Subjects = [...newSubjects];
      showSaveButton = true;
    });
  }

  void _updateSelectedYears(List<Year> newYears) {
    setState(() {
      Years = [...newYears];
      showSaveButton = true;
    });
  }

  Future<void> getData() async {
    DioHelper.getData(
        url: 'Admin/GetTeacherPrivilages',
        query: {'TeacherId': widget.TeacherId}).then(
      (value) {
        print(value.data["data"]["subjects"]);
        setState(() {
          TeacherData = Teacher.fromJson(value.data["additionalData"]);
          Subjects = (value.data["data"]["subjects"] as List)
              .map((item) => Subject.fromJson(item))
              .toList();
          Years = (value.data["data"]["years"] as List)
              .map((item) => Year.fromJson(item))
              .toList();
        });
      },
    );
  }

  Future<void> saveChanges() async {
    //SaveTeacherPrivilages(string UserId,LocalTeacherPrivilage t)
    await DioHelper.postData(url: 'Admin/SaveTeacherPrivilages', query: {
      'UserId': CacheHelper.getData(key: 'userId')
    }, data: {
      "teacherId": widget.TeacherId,
      "subjects":
          Subjects.where((element) => element.selected == true).toList(),
      "years": Years.where((element) => element.selected == true).toList()
    }).then(
      (value) {
        showToast(text: 'تم حفظ الصلاحيات بنجاح', state: ToastStates.SUCCESS);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, "صلاحيات المُعلم"),
        body: TeacherData == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  MainWidget(
                    context,
                    teacherData: TeacherData,
                    subjects: Subjects,
                    years: Years,
                    actionShowSubjects: () {
                      _showSubjects(true);
                    },
                    actionShowYears: () {
                      _showYears(true);
                    },
                    saveChanges: saveChanges,
                    showSaveButton: showSaveButton,
                  ),
                  Container(
                      color: Colors.white,
                      height: showSubjects ? double.infinity : 0,
                      child: SelectSubjectsWidget(
                        subjects: Subjects,
                        updateSubjects: _updateSelectedSubjects,
                        actionShowSubjects: () {
                          _showSubjects(false);
                        },
                      )),
                  Container(
                      color: Colors.white,
                      height: showYears ? double.infinity : 0,
                      child: SelectYearsWidget(
                        years: Years,
                        updateYears: _updateSelectedYears,
                        actionShowYears: () {
                          _showYears(false);
                        },
                      )),
                ],
              ));
  }
}

class MainWidget extends StatelessWidget {
  MainWidget(this.pageContext,
      {this.teacherData,
      this.subjects,
      this.years,
      this.actionShowSubjects,
      this.actionShowYears,
      this.saveChanges,
      this.showSaveButton,
      Key key})
      : super(key: key);
  Teacher teacherData;
  List<Subject> subjects;
  List<Year> years;
  Function actionShowSubjects;
  Function actionShowYears;
  Function saveChanges;
  bool showSaveButton;
  BuildContext pageContext;
  @override
  Widget build(BuildContext context) {
    var dataDate = DateTime.parse(teacherData.dataDate);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: CircleAvatar(
                      radius: 35,
                      child: teacherData.teacherPhoto == null
                          ? Image.asset(
                              'assets/images/Teacher.jpg',
                            )
                          : Image.network(teacherData.teacherPhotoUrlSource ==
                                  "api"
                              ? '${baseUrl0}assets/ProfileImages/${teacherData.teacherPhoto}'
                              : '${webUrl}images/Profiles/${teacherData.teacherPhoto}'),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacherData.fullName),
                      Text(
                          '${getDayName(dataDate.weekday, "ar")} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}'),
                      Text(teacherData.email),
                    ],
                  )),
                  IconButton(
                      onPressed: () async {
                        await FlutterPhoneDirectCaller.callNumber(
                            teacherData.phoneNumber);
                      },
                      icon: Image.asset(
                        'assets/images/phone.png',
                        width: 35,
                        height: 35,
                      ),
                      iconSize: 45),
                ],
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: InkWell(
              onTap: actionShowSubjects,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    subjects
                                .where((element) => element.selected == true)
                                .length ==
                            0
                        ? TextButton(
                            onPressed: actionShowSubjects,
                            child: Text("إختر المواد الدراسية"))
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: subjects
                                .where((element) => element.selected == true)
                                .length,
                            itemBuilder: (context, index) {
                              var item = subjects
                                  .where((element) => element.selected == true)
                                  .toList()[index];
                              return Container(
                                  margin: EdgeInsets.all(5),
                                  padding: item.parentSubjectId == null
                                      ? null
                                      : EdgeInsets.only(right: 10),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                        fontWeight: item.parentSubjectId == null
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ));
                            })
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: InkWell(
              onTap: actionShowYears,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    years.where((element) => element.selected == true).length ==
                            0
                        ? TextButton(
                            onPressed: actionShowYears,
                            child: Text("إختر السنوات الدراسية"))
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: years
                                .where((element) => element.selected == true)
                                .length,
                            itemBuilder: (context, index) {
                              var item = years
                                  .where((element) => element.selected == true)
                                  .toList()[index];
                              return Container(
                                  margin: EdgeInsets.all(5),
                                  child: Text(
                                    item.nameAra,
                                  ));
                            })
                  ],
                ),
              ),
            ),
          ),
          if (showSaveButton)
            Divider(
              height: 10,
              thickness: 2,
            ),
          if (showSaveButton)
            Container(
              padding: EdgeInsets.all(8),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(children: [
                  GestureDetector(
                      onTap: saveChanges,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.green,
                        ),
                        child: Text(
                          "حفظ التعديلات",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(pageContext).pop();
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black26,
                        ),
                        child: Text(
                          "إلغاء",
                          style: TextStyle(color: Colors.black87),
                        ),
                      )),
                ]),
              ),
            )
        ]),
      ),
    );
  }
}

class SelectSubjectsWidget extends StatelessWidget {
  SelectSubjectsWidget(
      {this.subjects, this.updateSubjects, this.actionShowSubjects, Key key})
      : super(key: key);
  List<Subject> subjects;
  Function updateSubjects;
  Function actionShowSubjects;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Expanded(
            child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: ((context, index) {
                  var item = subjects[index];
                  return InkWell(
                      onTap: () {
                        subjects
                                .firstWhere((element) => element.id == item.id)
                                .selected =
                            !subjects
                                .firstWhere((element) => element.id == item.id)
                                .selected;
                        updateSubjects([...subjects]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        child: Row(
                          children: [
                            if (item.parentSubjectId != null)
                              SizedBox(
                                width: 20,
                              ),
                            Expanded(
                                child: Text(
                              item.name,
                              style: TextStyle(
                                  color: item.selected
                                      ? Colors.green.shade600
                                      : Colors.black54,
                                  fontWeight: item.parentSubjectId == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18),
                            ))
                          ],
                        ),
                      ));
                })),
          ),
          Divider(height: 10, thickness: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                GestureDetector(
                    onTap: actionShowSubjects,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green,
                      ),
                      child: Text(
                        "موافق",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class SelectYearsWidget extends StatelessWidget {
  SelectYearsWidget(
      {this.years, this.updateYears, this.actionShowYears, Key key})
      : super(key: key);
  List<Year> years;
  Function updateYears;
  Function actionShowYears;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Expanded(
            child: ListView.builder(
                itemCount: years.length,
                itemBuilder: ((context, index) {
                  var item = years[index];
                  return InkWell(
                      onTap: () {
                        years
                                .firstWhere((element) => element.id == item.id)
                                .selected =
                            !years
                                .firstWhere((element) => element.id == item.id)
                                .selected;
                        updateYears([...years]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        child: Text(
                          item.nameAra,
                          style: TextStyle(
                              color: item.selected
                                  ? Colors.green.shade600
                                  : Colors.black54,
                              fontWeight: item.selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 18),
                        ),
                      ));
                })),
          ),
          Divider(height: 10, thickness: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                GestureDetector(
                    onTap: actionShowYears,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green,
                      ),
                      child: Text(
                        "موافق",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class Subject {
  int id;
  String name;
  int parentSubjectId;
  String dir;
  bool selected;

  Subject({this.id, this.name, this.parentSubjectId, this.dir, this.selected});

  Subject.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentSubjectId = json['parentSubjectId'];
    dir = json['dir'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['parentSubjectId'] = this.parentSubjectId;
    data['dir'] = this.dir;
    data['selected'] = this.selected;
    return data;
  }
}

class Year {
  int id;
  String nameAra;
  bool selected;

  Year({this.id, this.nameAra, this.selected});

  Year.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAra = json['nameAra'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nameAra'] = this.nameAra;
    data['selected'] = this.selected;
    return data;
  }
}

class Teacher {
  int id;
  String fullName;
  String email;
  String phoneNumber;
  String dataDate;
  String teacherPhoto;
  String teacherPhotoUrlSource;

  Teacher(
      {this.id,
      this.fullName,
      this.email,
      this.phoneNumber,
      this.dataDate,
      this.teacherPhoto,
      this.teacherPhotoUrlSource});

  Teacher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    dataDate = json['dataDate'];
    teacherPhoto = json['teacherPhoto'];
    teacherPhotoUrlSource = json['teacherPhotoUrlSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['dataDate'] = this.dataDate;
    data['teacherPhoto'] = this.teacherPhoto;
    data['teacherPhotoUrlSource'] = this.teacherPhotoUrlSource;
    return data;
  }
}
