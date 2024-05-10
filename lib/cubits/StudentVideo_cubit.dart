// import 'dart:convert';

// import 'package:bloc/bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_school/cubits/StudentVideo_states.dart';

// import 'package:my_school/screens/login_screen.dart';
// import 'package:my_school/shared/cache_helper.dart';
// import 'package:my_school/shared/components/components.dart';
// import 'package:my_school/shared/components/functions.dart';
// import 'package:my_school/shared/dio_helper.dart';

// class StudentVideoCubit extends Cubit<StudentVideoStates> {
//   StudentVideoCubit() : super(InitialState());
//   static StudentVideoCubit get(context) => BlocProvider.of(context);

//   var lang = CacheHelper.getData(key: "lang");
//   var token = CacheHelper.getData(key: "token");
//   // void getData() {
//   //   emit(LoadingState());
//   //   DioHelper.getData(
//   //           url: 'SchoolTypeYearOfStudy', query: {}, lang: lang, token: token)
//   //       .then((value) {
//   //     print(value.data["schoolTypes"]);
//   //     SchoolTypes =
//   //         SchoolTypesAndYearsOfStudies.fromJson(value.data).SchoolTypes;
//   //     YearsOfStudies =
//   //         SchoolTypesAndYearsOfStudies.fromJson(value.data).YearsOfStudies;

//   //     emit(SuccessState());
//   //   }).catchError((error) {
//   //     print(error.toString());
//   //     emit(ErrorState(error.toString()));
//   //   });
//   // }

//   void saveProgress(
//     context,
//     int StudentId,
//     int VideoId,
//     int CurrentSecond,
//   ) {
//     emit(SavingState());
//     DioHelper.postData(
//         url: 'StudentUpdateVideoProgress',
//         query: {},
//         lang: lang,
//         token: token,
//         data: {
//           "StudentId": StudentId,
//           "VideoId": VideoId,
//           "CurrentSecond": CurrentSecond,
//           "DataDate": DateTime.now(),
//         }).then((value) {
//       print(value.data);
//       if (value.data["status"] == false &&
//           value.data["message"] == "SessionExpired") {
//         handleSessionExpired(context);
//         return;
//       }
//       if (value.data["status"] == true) {
//         showToast(
//             text:
//                 lang == "en" ? "Saved Successfully!" : "تم حفظ الإعدادات بنجاح",
//             state: ToastStates.SUCCESS);
//       } else {
//         showToast(
//             text: lang == "en" ? "Something went wrong!" : "حدث خطأ ما!",
//             state: ToastStates.ERROR);
//         navigateAndFinish(context, LoginScreen());
//       }
//       emit(SuccessState());
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }
// }
