// import 'dart:convert';

// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_school/cubits/parentStudent_states.dart';
// import 'package:my_school/models/user/student.dart';
// import 'package:my_school/shared/components/components.dart';

// import 'package:my_school/shared/components/constants.dart';
// import 'package:my_school/shared/components/functions.dart';
// import 'package:my_school/shared/dio_helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';

// class ParentStudentCubit extends Cubit<ParentStudentStates> {
//   ParentStudentCubit() : super(InitialState());

//   static ParentStudentCubit get(context) => BlocProvider.of(context);

//   var students;
//   String lang;

//   void getStudents(context) async {
//     emit(LoadingState());
//     final prefs = await SharedPreferences.getInstance();
//     var token = await prefs.getString("token");
//     lang = await prefs.getString("lang");
   
//     DioHelper.getData(
//       query: {},
//       token: token,
//       url: "ParentStudents",
//     ).then((value) {
//       print('Value: ${value.data["data"]}');
//       if (value.data["status"] == false &&
//           value.data["message"] == "SessionExpired") {
//         handleSessionExpired(context);
//         return;
//       }
//       if (value.data["status"] == false) {
//         emit(UnAuthendicatedState());
//         return;
//       }
//       students = jsonDecode(value.data["data"])
//           .map((s) => Student.fromJson(s))
//           .toList();
//       emit(SuccessState(students));
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }
// }
