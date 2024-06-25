import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';

import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/constants.dart';

import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import 'package:http/http.dart' as http;

class StudentLessonSessionsProvider with ChangeNotifier {
  StudentLessonSessions get sessions {
    return studentLessonSessions;
  }

  bool isLoading = true;
  StudentLessonSessions studentLessonSessions;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');

  Future<void> getSessions(context, Id, LessonId) async {
    final response = await http.get(
        Uri.parse('${baseUrl}StudentLessonSessions?Id=$Id&LessonId=$LessonId'),
        headers: {'lang': lang});
    var value = json.decode(response.body);
    print(value["data"]);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }

    studentLessonSessions = StudentLessonSessions.fromJson(value["data"]);
    isLoading = false;
    notifyListeners();
  }
}
