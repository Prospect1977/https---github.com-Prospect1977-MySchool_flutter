import 'dart:io';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_school/models/login_model.dart';
import 'package:my_school/screens/forgot_password_screen.dart';
import 'package:my_school/screens/landing_screen.dart';

import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/register_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();

  UserData userData;

  bool isLoading = false;
  bool isSuccess;
  bool showPassword = false;
  void userLogin({
    @required String email,
    @required String password,
  }) {
    setState(() {
      isLoading = true;
    });

    DioHelper.postDataForLogin(
      url: "Account/login",
      //url: "WeatherForecast",
      data: {
        'email': email,
        'password': password,
      },
    ).then((value) {
      if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        setState(() {
          isLoading = false;
        });
        return;
      }
      print(value.data['data']);
      userData = UserData.fromJson(value.data['data']);
      CacheHelper.saveData(
          key: "isStudentHasParent", value: userData.isStudentHasParent);
      CacheHelper.saveData(key: "teacherId", value: userData.teacherId);
      CacheHelper.saveData(key: "fullName", value: userData.fullName);
      CacheHelper.saveData(key: "phoneNumber", value: userData.phoneNumber);
      CacheHelper.saveData(key: "userId", value: userData.userId);

      CacheHelper.saveData(key: "token", value: userData.token);
      CacheHelper.saveData(key: "roles", value: userData.roles);
      CacheHelper.saveData(key: "email", value: userData.email);
      if (userData.roles.toLowerCase().contains('student')) {
        CacheHelper.putBoolean(
            key: "isStudentHasParent",
            value: value.data["additionalData"]["isStudentHasParent"]);
      }
      print(
          "_____________________________________________IsStudentHasParent=${CacheHelper.getData(key: "isStudentHasParent")}");

      setState(() {
        isSuccess = true;
        isLoading = false;
      });
      String roles = userData.roles;
      if (roles.contains("Parent")) {
        navigateAndFinish(context, ParentsLandingScreen());
      }
      if (roles.contains("Student")) {
        navigateAndFinish(context, StudentDashboardScreen());
      }
      if (roles.contains("Teacher")) {
        navigateAndFinish(context, TeacherDashboardScreen());
      }
    }).catchError((error) {
      print(error.toString());
      setState(() {
        isSuccess = false;
        isLoading = false;
      });
    });
  }

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var lang = CacheHelper.getData(key: 'lang');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBarComponent(context, ""),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: lang == "ar"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      lang == "en" ? 'Login' : "تسجيل دخول",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black87.withOpacity(0.7),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: lang == "ar"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Directionality(
                      textDirection:
                          lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              lang == "ar" ? "أو " : "Or ",
                              style: TextStyle(fontSize: 18),
                            ),
                            defaultTextButton(
                              underline: false,
                              function: () {
                                navigateTo(
                                  context,
                                  RegisterScreen(),
                                );
                              },
                              fontSize: 20,
                              text:
                                  lang == "en" ? 'Register' : 'إنشاء حساب جديد',
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  defaultFormField(
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'please enter your email address'
                            : 'من فضلك أدخل البريد الإلكتروني';
                      }
                      if (!value.trim().contains('@')) {
                        return lang == "ar"
                            ? "البريد الإلكتروني ليس مكتوباً بشكل صحيح"
                            : "Email format is incorrect!";
                      }
                    },
                    onChange: (value) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                    label: lang == "en" ? 'Email Address' : "البريد الإلكتروني",
                    prefix: Icons.email_outlined,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  defaultFormField(
                    controller: passwordController,
                    type: TextInputType.visiblePassword,
                    suffix: !showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSubmit: (value) {
                      if (formKey.currentState.validate()) {
                        userLogin(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      }
                    },
                    isPassword: !showPassword,
                    suffixPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                        isLoading = false;
                      });
                    },
                    onChange: (value) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'password is too short'
                            : 'كلمة المرور قصيرة جداً';
                      }
                    },
                    label: lang == "en" ? 'Password' : "كلمة المرور",
                    prefix: Icons.lock_outline,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    margin: EdgeInsets.all(0),
                    child: defaultTextButton(
                      color: defaultColor.withOpacity(0.7),
                      function: () {
                        navigateTo(
                          context,
                          ForgotPasswordScreen(),
                        );
                      },
                      fontSize: 18,
                      text: lang == "en"
                          ? 'Forgot Password?'
                          : "نسيت كلمة المرور؟",
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : defaultButton(
                          function: () {
                            if (formKey.currentState.validate()) {
                              userLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          borderRadius: 5,
                          text: lang == "en" ? 'Login' : "دخول",
                          isUpperCase: false,
                        ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
