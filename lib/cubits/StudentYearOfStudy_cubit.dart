import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentYearOfStudy_states.dart';

import 'package:my_school/models/SchoolTypeYearOfStudy.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentYearOfStudyCubit extends Cubit<StudentYearOfStudyStates> {
  StudentYearOfStudyCubit() : super(InitialState());
  static StudentYearOfStudyCubit get(context) => BlocProvider.of(context);
  List<SchoolType> SchoolTypes;
  List<YearOfStudy> YearsOfStudies;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  void getData() {
    emit(LoadingState());
    DioHelper.getData(
            url: 'SchoolTypeYearOfStudy', query: {}, lang: lang, token: token)
        .then((value) {
      print(value.data["schoolTypes"]);
      SchoolTypes =
          SchoolTypesAndYearsOfStudies.fromJson(value.data).SchoolTypes;
      YearsOfStudies =
          SchoolTypesAndYearsOfStudies.fromJson(value.data).YearsOfStudies;

      emit(SuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }

  void saveData(context, int id, String gender, String fullName,
      int schoolTypeId, int YearOfStudyId) {
    emit(SavingState());
    DioHelper.postData(
        url: 'SchoolTypeYearOfStudy',
        query: {},
        lang: lang,
        token: token,
        data: {
          "id": id,
          "gender": gender,
          "fullName": fullName,
          "schoolTypeId": schoolTypeId,
          "yearOfStudyId": YearOfStudyId
        }).then((value) {
      print(value.data);
      if (value.data["status"] == true) {
        showToast(
            text:
                lang == "en" ? "Saved Successfully!" : "تم حفظ الإعدادات بنجاح",
            state: ToastStates.SUCCESS);
      } else {
        showToast(
            text: lang == "en" ? "Something went wrong!" : "حدث خطأ ما!",
            state: ToastStates.ERROR);
        navigateAndFinish(context, LoginScreen());
      }
      emit(SuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }
}
