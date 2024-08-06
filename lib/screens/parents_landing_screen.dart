import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_school/models/user/student.dart';
import 'package:my_school/screens/add_student_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/wallet_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';

import '../shared/styles/colors.dart';

class ParentsLandingScreen extends StatefulWidget {
  const ParentsLandingScreen({Key key}) : super(key: key);

  @override
  State<ParentsLandingScreen> createState() => _ParentsLandingScreenState();
}

class _ParentsLandingScreenState extends State<ParentsLandingScreen> {
  var students;
  String lang = CacheHelper.getData(key: 'lang');
  var token = CacheHelper.getData(key: 'token');
  void getStudents() async {
    if (CacheHelper.getData(key: 'studentsList') != null) {
      setState(() {
        print(CacheHelper.getData(key: 'studentsList'));
        students = jsonDecode(CacheHelper.getData(key: 'studentsList'))
            .map((s) => Student.fromJson(s))
            .toList();
      });
    } else {
      students = null;
      await DioHelper.getData(
        query: {},
        token: token,
        url: "ParentStudents",
      ).then((value) {
        print('Value: ${value.data["data"]}');
        if (value.data["status"] == false &&
            value.data["message"] == "SessionExpired") {
          handleSessionExpired(context);
          return;
        } else if (value.data["status"] == false) {
          showToast(text: value.data["message"], state: ToastStates.ERROR);
          return;
        }
        setState(() {
          students = jsonDecode(value.data["data"])
              .map((s) => Student.fromJson(s))
              .toList();
          //print(jsonDecode(students));
          CacheHelper.saveData(key: 'studentsList', value: value.data["data"]);
        });
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
      });
    }
  }

  void DeleteChild(Id) {
    DioHelper.postData(
      query: {"StudentId": Id},
      token: token,
      url: "ParentStudents/DeleteChild",
    ).then((value) {
      print('Value: ${value.data["data"]}');
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        CacheHelper.saveData(key: 'studentsList', value: value.data["data"]);
        students = jsonDecode(value.data["data"])
            .map((s) => Student.fromJson(s))
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
    getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getStudents();
      },
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
              backgroundColor: defaultColor,
              child: Image.asset(
                'assets/images/wallet.png',
                width: 30,
              ),
              onPressed: () {
                navigateTo(context, WalletScreen());
              }),
          appBar:
              appBarComponent(context, lang == "ar" ? "الأبناء" : "Students"),
          body: students == null
              ? Center(
                  child: Directionality(
                      textDirection:
                          lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang == "ar"
                                  ? "جاري تحميل بيانات الطلاب..."
                                  : "Loading students data...",
                              style: TextStyle(
                                  fontSize: 22, color: Colors.black45),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            CircularProgressIndicator(color: Colors.green),
                          ],
                        ),
                      )),
                )
              : Directionality(
                  textDirection:
                      lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      navigateTo(
                                          context,
                                          StudentDashboardScreen(
                                            Id: students[index].Id,
                                            FullName: students[index].FullName,
                                            Gender: students[index].Gender,
                                            SchoolTypeId:
                                                students[index].SchoolTypeId,
                                            YearOfStudyId:
                                                students[index].YearOfStudyId,
                                          ));
                                    },
                                    child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(65),
                                            border: Border.all(
                                                color: Colors.black45,
                                                width: 2)),
                                        child: students[index].Gender == null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(55)),
                                                child: Icon(
                                                  Icons.account_circle,
                                                  size: 50,
                                                  color: Colors.black38,
                                                ),
                                              )
                                            : (students[index].Gender ==
                                                    "Female"
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                55)),
                                                    child: Image.asset(
                                                      "assets/images/girlAvatar.jpg",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                55)),
                                                    child: Image.asset(
                                                      "assets/images/boyAvatar.jpg",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )),
                                      ),
                                      title: Text(
                                        students[index].FullName,
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black54),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.black45,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => Directionality(
                                                  textDirection: lang == "en"
                                                      ? TextDirection.ltr
                                                      : TextDirection.rtl,
                                                  child: AlertDialog(
                                                      titleTextStyle: TextStyle(
                                                          color: defaultColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      title: Text(lang == "en"
                                                          ? 'Are you sure?'
                                                          : "هل انت متأكد؟"),
                                                      content: Text(
                                                        lang == "en"
                                                            ? 'Are you sure that you want to remove this student?'
                                                            : "هل تريد حذف الطالب؟",
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text(
                                                              lang == "en"
                                                                  ? "No"
                                                                  : "لا"),
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                            child: Text(
                                                                lang == "en"
                                                                    ? 'Yes'
                                                                    : "نعم"),
                                                            onPressed: () {
                                                              DeleteChild(
                                                                  students[
                                                                          index]
                                                                      .Id);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ])));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // ElevatedButton(onPressed: (){}), child: child)
                        defaultButton(
                            function: () {
                              navigateTo(context, AddStudentScreen());
                            },
                            text: lang == "en" ? 'Add a Student' : 'إضافة طالب',
                            isUpperCase: false,
                            borderRadius: 0,
                            fontWeight: FontWeight.bold,
                            background: Colors.green.shade700)
                      ],
                    ),
                  ),
                )),
    );
  }
}
