import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentDashboard_states.dart';
import 'package:my_school/models/user/student.dart';
import 'package:my_school/shared/cache_helper.dart';

import 'package:my_school/shared/dio_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardCubit extends Cubit<StudentDashboardStates> {
  StudentDashboardCubit() : super(InitialState());

  static StudentDashboardCubit get(context) => BlocProvider.of(context);

  var student;
  int Id;
  String FullName;
  String Gender;
  int YearOfStudyId;
  int SchoolTypeId;
  void getStudent() async {
    emit(LoadingState());
    final prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    var q = {'UserId': CacheHelper.getData(key: 'userId')};
    print(q);
    DioHelper.getData(
      query: q,
      // token: token,
      url: "StudentMainDataByUserId",
    ).then((value) {
      Id = value.data["studentId"];
      FullName = value.data["fullName"];
      Gender = value.data["gender"];
      YearOfStudyId = value.data["yearOfStudyId"];
      SchoolTypeId = value.data["schoolTypeId"];
      emit(SuccessState(student));
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }
}
