import 'package:flutter/cupertino.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/models/admin_lesson.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../models/Quiz_model.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurriculumProvider with ChangeNotifier {
  List<AdminLesson> get items {
    return [...lessons];
  }

  bool isLoading = true;
  var lessons;
  List<AdminLesson> lessonsWithNoParent;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');
  String CurriculumName;
  String YearOfStudyName;
  String TermName;
  bool showReorderTip = false;
  Future<void> getData(int YearSubjectId, int TermIndex) async {
    var url = Uri.parse(
      '${baseUrl}Lessons/LessonsByYearSujectId?YearSubjectId=$YearSubjectId&TermIndex=$TermIndex',
    );
    final response = await http.get(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }

    lessons = AdminLessons.fromJson(value["data"]).items;
    lessonsWithNoParent =
        lessons.where((m) => m.parentLessonId == null).toList();
    if (lessons.length > 1) {
      showReorderTip = true;
    } else {
      showReorderTip = false;
    }
    isLoading = false;
    var additionalData = value["additionalData"];
    CurriculumName = additionalData["curriculumName"];
    YearOfStudyName = additionalData["yearOfStudyName"];
    TermName = additionalData["termName"];

    notifyListeners();
  }

  Future<void> DeleteLesson(int LessonId) async {
    isLoading = true;
    notifyListeners();

    var url = Uri.parse(
      '${baseUrl}Lessons/DeleteLesson?LessonId=$LessonId&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      showToast(text: value["message"], state: ToastStates.WARNING);
    }
  }

  Future<void> CreateLesson(
      //TermIndex,YearSubjectId,Name,Description,SortIndex,Active,ParentLessonId,BlockedFromAddingSessions
      {context,
      int TermIndex,
      int YearSubjectId,
      String Name,
      String Description,
      bool Active,
      int ParentLessonId,
      bool BlockedFromAddingSessions}) async {
    // var url = Uri.parse(
    //   '${baseUrl}Lessons/CreateLesson?Description=${Description == "" ? null : Description}&UserId=${CacheHelper.getData(key: 'userId')}&TermIndex=$TermIndex&YearSubjectId=$YearSubjectId&Name=$Name&Active=$Active&ParentLessonId=$ParentLessonId&BlockedFromAddingSessions=$BlockedFromAddingSessions',
    // );
    // try {
    //   final response = await http.post(url, headers: {
    //     'lang': lang,
    //     'Authorization': 'Bearer $token',
    //     'Content-type': 'application/json',
    //     'Accept': 'application/json',
    //   });
    //   var value = json.decode(response.body);
    //   if (value["status"] == false && value["message"] == "SessionExpired") {
    //     showToast(
    //         text: lang == "ar"
    //             ? "من فضلك قم بتسجيل الدخول مجدداً"
    //             : 'Session Expired, please login again',
    //         state: ToastStates.ERROR);
    //     return;
    //   } else if (value["status"] == false) {
    //     showToast(text: value["message"], state: ToastStates.ERROR);
    //     return;
    //   } else {}
    // } catch (ex) {
    //   print(ex.toString());
    // }
    await DioHelper.postData(
        url: "Lessons/CreateLesson",
        lang: lang,
        token: token,
        query: {
          "TermIndex": TermIndex,
          "YearSubjectId": YearSubjectId,
          "Name": Name,
          "Description": Description == "" ? null : Description,
          "Active": Active,
          "UserId": CacheHelper.getData(key: 'userId'),
          "ParentLessonId": ParentLessonId,
          "BlockedFromAddingSessions": BlockedFromAddingSessions,
        },
        data: {}).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        showToast(
            text: lang == "ar"
                ? "من فضلك قم بتسجيل الدخول مجدداً"
                : 'Session Expired, please login again',
            state: ToastStates.ERROR);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {}
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> EditLessson(
      //TermIndex,YearSubjectId,Name,Description,SortIndex,Active,ParentLessonId,BlockedFromAddingSessions
      {context,
      int Id,
      int TermIndex,
      int YearSubjectId,
      String Name,
      String Description,
      bool Active,
      int ParentLessonId,
      bool BlockedFromAddingSessions}) async {
    var url = Uri.parse(
      '${baseUrl}Lessons/EditLesson?Id=$Id&Description=$Description&UserId=${CacheHelper.getData(key: 'userId')}& TermIndex=$TermIndex&YearSubjectId=$YearSubjectId&Name=$Name&Active=$Active&ParentLessonId=$ParentLessonId&BlockedFromAddingSessions=$BlockedFromAddingSessions',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {}
  }

  Future<void> SwitchTermIndex({int LessonId}) async {
    var url = Uri.parse(
      '${baseUrl}Lessons/SwitchTermIndex?LessonId=$LessonId&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      // var lessonsCopy = [...lessons];
      // lessonsCopy.removeWhere((element) => element.id == LessonId);
      // lessons = lessonsCopy;
      // notifyListeners();
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }

  Future<void> SwitchLessonActive({context, int LessonId}) async {
    var url = Uri.parse(
      '${baseUrl}Lessons/SwitchLessonActive?LessonId=$LessonId',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      var lessonsCopy = [...lessons];
      var isActive =
          lessonsCopy.firstWhere((element) => element.id == LessonId).active;
      lessonsCopy.firstWhere((element) => element.id == LessonId).active =
          !isActive;
      lessons = lessonsCopy;
      notifyListeners();
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }

  Future<void> SwitchLessonBlock({context, int LessonId}) async {
    final url = Uri.parse(
      '${baseUrl}Lessons/SwitchLessonBlock?LessonId=$LessonId&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      List<AdminLesson> lessonsCopy = [...lessons];
      var isBlocked = lessonsCopy
          .firstWhere((element) => element.id == LessonId)
          .blockedFromAddingSessions;
      lessonsCopy
          .firstWhere((element) => element.id == LessonId)
          .blockedFromAddingSessions = !isBlocked;
      lessons = [...lessonsCopy];

      notifyListeners();
      // showToast(text: value.data["message"], state: ToastStates.SUCCESS);
    }
  }

  void OrderLessons(context, String LessonsList) async {
    final url = Uri.parse(
      '${baseUrl}Lessons/OrderLessons?LessonsList=$LessonsList&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      // notifyListeners();
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }
}
