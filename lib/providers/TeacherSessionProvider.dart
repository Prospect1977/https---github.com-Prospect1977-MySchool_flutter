import 'package:flutter/cupertino.dart';

import 'package:my_school/models/teacher_session.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    var url = Uri.parse(
      '${baseUrl}TeacherSession?TeacherId=$TeacherId&LessonId=$LessonId&DataDate=${DateTime.now()}',
    );
    final response = await http.get(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }

    teacherSession = TeacherSession.fromJson(value['data']);
    isSessionActive = teacherSession.active;
    isLoading = false;
    notifyListeners();
  }

  void DeleteSessionDetail(context, int SessionDetailId, int TeacherId) async {
    var url = Uri.parse(
      '${baseUrl}TeacherSession/DeleteSessionDetail?TeacherId=$TeacherId&SessionDetailId=$SessionDetailId&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }
  }

  void ActivateSessionDetail(
      context, int SessionDetailId, int TeacherId) async {
    var url = Uri.parse(
      '${baseUrl}TeacherSession/ActivateSessionDetail?TeacherId=$TeacherId&SessionDetailId=$SessionDetailId&UserId=${CacheHelper.getData(key: 'userId')}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }
    showToast(
        text: lang == "en" ? "Saved Successfully!" : "تم الحفظ بنجاح!",
        state: ToastStates.SUCCESS);
  }

  void DeactivateSessionDetail(
      context, int SessionDetailId, int TeacherId) async {
    var url = Uri.parse(
      '${baseUrl}TeacherSession/DeactivateSessionDetail?TeacherId=$TeacherId&UserId=${CacheHelper.getData(key: 'userId')}&SessionDetailId=$SessionDetailId',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }
    showToast(
        text: lang == "en" ? "Saved Successfully!" : "تم الحفظ بنجاح!",
        state: ToastStates.SUCCESS);
  }

//'Content-Type': 'multipart/form-data',
  void UploadVideoThumnail(context, int VideoId, formData) async {
    // var url = Uri.parse(
    //   '${baseUrl}TeacherSession/TeacherUploadVideoThumbnail?VideoId=$VideoId',
    // );
    // final response = await http.post(url,
    //     headers: {
    //       "lang": lang,
    //       'Authorization': 'Bearer $token',
    //       'Content-Type': 'multipart/form-data'
    //     },
    //     body: formData);
    // var value = json.decode(response.body);

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
    var url = Uri.parse(
      '${baseUrl}TeacherSession/UpdateSessionDetailTitle?UserId=${CacheHelper.getData(key: 'userId')}&TeacherId=$TeacherId&SessionDetailId=$sessionDetailId&Title=$Title',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      Navigator.of(context).pop();
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }

  void ReorderSessionDetails(context, int TeacherId, String ids) async {
    var url = Uri.parse(
      '${baseUrl}TeacherSession/ReorderSessionDetails?UserId=${CacheHelper.getData(key: 'userId')}&SessionDetailsList=$ids&TeacherId=$TeacherId',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }
}
