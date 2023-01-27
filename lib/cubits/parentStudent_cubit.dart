import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/parentStudent_states.dart';
import 'package:my_school/models/user/student.dart';

import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ParentStudentCubit extends Cubit<ParentStudentStates> {
  ParentStudentCubit() : super(InitialState());

  static ParentStudentCubit get(context) => BlocProvider.of(context);

  var students;
  String lang;

  void getStudents() async {
    emit(LoadingState());
    final prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    lang = await prefs.getString("lang");
    // var token = await CacheHelper.getData(key: "token");

    // var dio = new Dio();
    // var value = await dio
    //     .get('$baseUrl/parentStudents',
    //         options: Options(headers: {
    //           'Content-Type': 'application/json',
    //           'lang': "ar",
    //           'Authorization': 'Bearer $token',
    //         }))
    //     .catchError((error) {
    //   print('Error: ${error.toString()}');
    //   emit(ErrorState(error.toString()));
    // });
    // print('Response: ${value.data}');
    // students = value.data.map((s) => Student.fromJson(s)).toList();
    // emit(SuccessState(students));

    DioHelper.getData(
      query: {},
      token: token,
      url: "ParentStudents",
    ).then((value) {
      print('Value: ${value.data["data"]}');
      if (value.data["status"] == false) {
        emit(UnAuthendicatedState());
        return;
      }
      students = jsonDecode(value.data["data"])
          .map((s) => Student.fromJson(s))
          .toList();
      emit(SuccessState(students));
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }
}
