import 'package:flutter/cupertino.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';

import 'package:my_school/shared/cache_helper.dart';

import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class StudentLessonSessionsProvider with ChangeNotifier {
  StudentLessonSessions get sessions {
    return studentLessonSessions;
  }

  bool isLoading = true;
  StudentLessonSessions studentLessonSessions;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');

  Future<void> getSessions(context, Id, LessonId) async {
    await DioHelper.getData(
            url: 'StudentLessonSessions',
            query: {'Id': Id, 'LessonId': LessonId},
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

      studentLessonSessions =
          StudentLessonSessions.fromJson(value.data["data"]);
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }
}
