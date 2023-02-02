import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentLessonSessionsProvider with ChangeNotifier {
  StudentLessonSessions StudentLessonSessionCollection;
  StudentLessonsByYearSubjectId_collection
      StudentLessonsByYearSubjectIdCollection;

  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  var currentLessonIndex = 0;
  Future<void> getSessions(Id, LessonId, context) async {
    DioHelper.getData(
            url: 'StudentLessonSessions',
            query: {'Id': Id, 'LessonId': LessonId},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["data"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      StudentLessonSessionCollection =
          StudentLessonSessions.fromJson(value.data["data"]);

      notifyListeners();
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<void> getLessons(Id, YearSubjectId, LessonId, context) async {
    DioHelper.getData(
            url: 'LessonsByYearSubjectId',
            query: {'Id': Id, 'YearSubjectId': YearSubjectId},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      StudentLessonsByYearSubjectIdCollection =
          StudentLessonsByYearSubjectId_collection.fromJson(value.data["data"]);
      var i = 0;
      while (i < StudentLessonsByYearSubjectIdCollection.items.length) {
        if (StudentLessonsByYearSubjectIdCollection.items[i].id == LessonId) {
          currentLessonIndex = i;
        }
        i++;
      }
      notifyListeners();
    }).catchError((error) {
      print(error.toString());
    });
  }
}
