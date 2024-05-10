// import 'dart:convert';

// import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_school/cubits/StudentSelectedSubject_states.dart';
// import 'package:my_school/models/StudentSubject.dart';
// import 'package:my_school/models/user/student.dart';
// import 'package:my_school/screens/login_screen.dart';
// import 'package:my_school/screens/studentDailySchedule_screen.dart';
// import 'package:my_school/shared/cache_helper.dart';
// import 'package:my_school/shared/components/components.dart';
// import 'package:my_school/shared/components/functions.dart';
// import 'package:my_school/shared/dio_helper.dart';

// class StudentSelectedSubjectsCubit
//     extends Cubit<StudentSelectedSubjectsStates> {
//   final int Id;
//   StudentSelectedSubjectsCubit(this.Id) : super(InitialState());

//   static StudentSelectedSubjectsCubit get(context) => BlocProvider.of(context);

//   var StudentSubjectsList;

//   void getSubjectsList(context) async {
//     emit(LoadingState());

//     var token = CacheHelper.getData(key: 'token');
//     var lang = CacheHelper.getData(key: 'lang');
//     DioHelper.getData(
//       lang: lang,
//       query: {"Id": Id},
//       token: token,
//       url: "StudentSelectedSubjects",
//     ).then((value) {
//       if (value.data["status"] == false &&
//           value.data["message"] == "SessionExpired") {
//         handleSessionExpired(context);
//       }
//       if (value.data["status"] == false) {
//         emit(UnAuthendicatedState());
//         CacheHelper.removeData(key: "userId");
//         CacheHelper.removeData(key: "token");
//         CacheHelper.removeData(key: "roles");
//         return;
//       }
//       print(value.data['data']);
//       StudentSubjectsList = jsonDecode(value.data['data'])
//           .map((s) => StudentSubject.fromJson(s))
//           .toList();
//       emit(SuccessState(StudentSubjectsList));
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);

//       emit(ErrorState(error.toString()));
//     });
//   }

//   void saveSubjectsList(context, List<int> SubjectsList) async {
//     // emit(LoadingState());

//     var token = CacheHelper.getData(key: 'token');
//     var lang = CacheHelper.getData(key: 'lang');
//     DioHelper.postData(
//       lang: lang,
//       data: {"selectedYearsSubjectIds": SubjectsList},
//       query: {"Id": Id},
//       token: token,
//       url: "StudentSelectedSubjects",
//     ).then((value) {
//       if (value.data["status"] == false &&
//           value.data["message"] == "SessionExpired") {
//         handleSessionExpired(context);
//       }
//       if (value.data["status"] == false) {
//         emit(UnAuthendicatedState());
//         CacheHelper.removeData(key: "userId");
//         CacheHelper.removeData(key: "token");
//         CacheHelper.removeData(key: "roles");
//         navigateAndFinish(context, LoginScreen());
//       }
//       print(value.data['data']);
//       showToast(
//           text: lang == "en"
//               ? "Selected subjects saved successfully!"
//               : "تم حفظ المواد المختارة بنجاح!",
//           state: ToastStates.SUCCESS);
//       Navigator.of(context).pop();
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }
// }
