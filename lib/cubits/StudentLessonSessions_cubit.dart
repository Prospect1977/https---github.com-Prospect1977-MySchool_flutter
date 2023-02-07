import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentLessonSessions_states.dart';

import 'package:my_school/models/SchoolTypeYearOfStudy.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentLessonSessionsCubit extends Cubit<StudentLessonSessionsStates> {
  StudentLessonSessionsCubit() : super(InitialState());
  static StudentLessonSessionsCubit get(context) => BlocProvider.of(context);
  StudentLessonSessions StudentLessonSessionCollection;
  StudentLessonsByYearSubjectId_collection
      StudentLessonsByYearSubjectIdCollection;

  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  var currentLessonIndex = 0;
  // void getSessions(Id, LessonId) {
  //   emit(LoadingState());
  //   DioHelper.getData(
  //           url: 'StudentLessonSessions',
  //           query: {'Id': Id, 'LessonId': LessonId},
  //           lang: lang,
  //           token: token)
  //       .then((value) {
  //     print(value.data["data"]);
  //     if (value.data["data"] == false) {
  //       emit(UnAuthendicatedState());
  //       return;
  //     }
  //     StudentLessonSessionCollection =
  //         StudentLessonSessions.fromJson(value.data["data"]);

  //     emit(SuccessState());
  //   }).catchError((error) {
  //     print(error.toString());
  //     emit(ErrorState(error.toString()));
  //   });
  // }

  // void getLessons(Id, YearSubjectId, LessonId) {
  //   emit(LoadingState());
  //   DioHelper.getData(
  //           url: 'LessonsByYearSubjectId',
  //           query: {'Id': Id, 'YearSubjectId': YearSubjectId},
  //           lang: lang,
  //           token: token)
  //       .then((value) {
  //     print(value.data["data"]);
  //     if (value.data["status"] == false) {
  //       emit(UnAuthendicatedState());
  //       return;
  //     }
  //     StudentLessonsByYearSubjectIdCollection =
  //         StudentLessonsByYearSubjectId_collection.fromJson(value.data["data"]);
  //     var i = 0;
  //     while (i < StudentLessonsByYearSubjectIdCollection.items.length) {
  //       if (StudentLessonsByYearSubjectIdCollection.items[i].id == LessonId) {
  //         currentLessonIndex = i;
  //       }
  //       i++;
  //     }

  //     emit(SuccessState());
  //   }).catchError((error) {
  //     print(error.toString());
  //     emit(ErrorState(error.toString()));
  //   });
  // }
}
