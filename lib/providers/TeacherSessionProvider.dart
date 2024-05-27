import 'package:flutter/cupertino.dart';

import 'package:my_school/models/teacher_session.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class TeacherSessionProvider with ChangeNotifier {
  TeacherSession get session {
    return teacherSession;
  }

  bool isLoading = true;
  TeacherSession teacherSession = null;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');
  bool isSessionActive;
  Future<void> getData(
    context,
    int TeacherId,
    int LessonId,
  ) async {
    // isLoading = true;
    // notifyListeners();
    await DioHelper.getData(
            url: "TeacherSession",
            query: {
              "TeacherId": TeacherId,
              "LessonId": LessonId,
              "DataDate": DateTime.now()
            },
            token: token,
            lang: lang)
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

      teacherSession = TeacherSession.fromJson(value.data['data']);
      isSessionActive = teacherSession.active;
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void DeleteSessionDetail(context, int SessionDetailId, int TeacherId) async {
    await DioHelper.postData(
            url: 'TeacherSession/DeleteSessionDetail',
            query: {
              'TeacherId': TeacherId,
              "SessionDetailId": SessionDetailId,
              "UserId": CacheHelper.getData(key: 'userId')
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void ActivateSessionDetail(
      context, int SessionDetailId, int TeacherId) async {
    await DioHelper.postData(
            url: 'TeacherSession/ActivateSessionDetail',
            query: {
              'TeacherId': TeacherId,
              "SessionDetailId": SessionDetailId,
              "UserId": CacheHelper.getData(key: 'userId')
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      showToast(
          text: lang == "en" ? "Saved Successfully!" : "تم الحفظ بنجاح!",
          state: ToastStates.SUCCESS);
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void DeactivateSessionDetail(
      context, int SessionDetailId, int TeacherId) async {
    await DioHelper.postData(
            url: 'TeacherSession/DeactivateSessionDetail',
            query: {
              'TeacherId': TeacherId,
              "SessionDetailId": SessionDetailId,
              "UserId": CacheHelper.getData(key: 'userId')
            },
            lang: lang,
            token: token)
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      showToast(
          text: lang == "en" ? "Saved Successfully!" : "تم الحفظ بنجاح!",
          state: ToastStates.SUCCESS);
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void UploadVideoThumnail(context, int VideoId, formData) async {
    await DioHelper.postImage(
            url: 'TeacherSession/TeacherUploadVideoThumbnail',
            data: formData,
            query: {"VideoId": VideoId},
            lang: "en",
            token: "")
        .then((value) {
      print(value.data);
    });
  }

  void updateTitle(
      {context, int sessionDetailId, int TeacherId, String Title}) async {
    isLoading = true;
    notifyListeners();
    DioHelper.postData(
        url: "TeacherSession/UpdateSessionDetailTitle",
        lang: lang,
        token: token,
        data: {},
        query: {
          "TeacherId": TeacherId,
          "SessionDetailId": sessionDetailId,
          "Title": Title,
          "UserId": CacheHelper.getData(key: 'userId'),
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        Navigator.of(context).pop();
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    });
  }

  void ReorderSessionDetails(context, int TeacherId, String ids) async {
    await DioHelper.postData(
        url: "TeacherSession/ReorderSessionDetails",
        lang: lang,
        token: token,
        data: {},
        query: {
          "TeacherId": TeacherId,
          'SessionDetailsList': ids,
          "UserId": CacheHelper.getData(key: 'userId')
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }
}
