import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_school/models/login_model.dart';
import 'package:my_school/cubits/login_states.dart';
import 'package:my_school/models/user/user_model.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/end_points.dart';
import 'package:my_school/shared/dio_helper.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  UserData userData;

  void userLogin({
    @required String email,
    @required String password,
  }) {
    emit(LoginLoadingState());
    // var future = new Future.delayed(const Duration(seconds: 15));
    // var sub=future.asStream().listen();
    // showToast(
    //     text: "Login failed, Please check your Email and Password",
    //     state: ToastStates.ERROR);
    // emit(UnAuthendicatedState());

    //your async 'await' codes goes here

    DioHelper.postDataForLogin(
      url: "Account/login",
      //url: "WeatherForecast",
      data: {
        'email': email,
        'password': password,
      },
    ).then((value) {
      print(value.data);
      userData = UserData.fromJson(value.data);
      CacheHelper.putBoolean(
          key: "studentHasParent", value: userData.studentHasParent);
      CacheHelper.saveData(key: "teacherId", value: userData.teacherId);
      CacheHelper.saveData(key: "fullName", value: userData.fullName);
      print(
          "_____________________________________________IsStudentHasParent=${CacheHelper.getData(key: "studentHasParent")}");
      // CacheHelper.saveData(key: "token", value: loginModel.data.token); handled on the login screen
      // CacheHelper.saveData(key: "roles", value: loginModel.data.roles);
      emit(LoginSuccessState(userData));
    }).catchError((error) {
      print(error.toString());
      emit(LoginErrorState(error.toString()));
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(ChangePasswordVisibilityState());
  }
}
