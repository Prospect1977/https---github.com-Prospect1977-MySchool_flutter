import 'package:flutter/cupertino.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/models/admin_lesson.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../models/Quiz_model.dart';
import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

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
    DioHelper.getData(
            url: "Lessons/LessonsByYearSujectId",
            query: {
              "YearSubjectId": YearSubjectId,
              "TermIndex": TermIndex,
            },
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
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
      }

      lessons = AdminLessons.fromJson(value.data["data"]).items;
      lessonsWithNoParent =
          lessons.where((m) => m.parentLessonId == null).toList();
      if (lessons.length > 1) {
        showReorderTip = true;
      } else {
        showReorderTip = false;
      }
      isLoading = false;
      var additionalData = value.data["additionalData"];
      CurriculumName = additionalData["curriculumName"];
      YearOfStudyName = additionalData["yearOfStudyName"];
      TermName = additionalData["termName"];

      notifyListeners();
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> DeleteLesson(int LessonId) async {
    isLoading = true;
    notifyListeners();
    await DioHelper.postData(
        url: "Lessons/DeleteLesson",
        lang: lang,
        token: token,
        data: {},
        query: {
          "LessonId": LessonId,
        }).then((value) {
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
      } else {
        showToast(text: value.data["message"], state: ToastStates.WARNING);
      }
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
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
    await DioHelper.postData(
        url: "Lessons/EditLesson",
        lang: lang,
        token: token,
        query: {
          "Id": Id,
          "TermIndex": TermIndex,
          "YearSubjectId": YearSubjectId,
          "Name": Name,
          "Description": Description,
          "Active": Active,
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

  Future<void> SwitchTermIndex({int LessonId}) async {
    await DioHelper.postData(
        url: "Lessons/SwitchTermIndex",
        lang: lang,
        token: token,
        data: {},
        query: {
          "LessonId": LessonId,
        }).then((value) {
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
      } else {
        // var lessonsCopy = [...lessons];
        // lessonsCopy.removeWhere((element) => element.id == LessonId);
        // lessons = lessonsCopy;
        // notifyListeners();
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> SwitchLessonActive({context, int LessonId}) async {
    await DioHelper.postData(
        url: "Lessons/SwitchLessonActive",
        lang: lang,
        token: token,
        data: {},
        query: {
          "LessonId": LessonId,
        }).then((value) {
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
      } else {
        var lessonsCopy = [...lessons];
        var isActive =
            lessonsCopy.firstWhere((element) => element.id == LessonId).active;
        lessonsCopy.firstWhere((element) => element.id == LessonId).active =
            !isActive;
        lessons = lessonsCopy;
        notifyListeners();
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> SwitchLessonBlock({context, int LessonId}) async {
    await DioHelper.postData(
        url: "Lessons/SwitchLessonBlock",
        lang: lang,
        token: token,
        data: {},
        query: {
          "LessonId": LessonId,
        }).then((value) {
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
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void OrderLessons(context, String LessonsList) async {
    await DioHelper.postData(
        url: "Lessons/OrderLessons",
        lang: lang,
        token: token,
        data: {},
        query: {
          "LessonsList": LessonsList,
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        // notifyListeners();
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }
}
