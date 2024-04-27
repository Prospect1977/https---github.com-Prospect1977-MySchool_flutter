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
      print(value.data);
      userData = UserData.fromJson(value.data["data"]);
      if (value.data["message"] != null) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        setState(() {
          isLoading = false;
        });
        return;
      }
      CacheHelper.saveData(
          key: "studentHasParent", value: userData.studentHasParent);
      CacheHelper.saveData(key: "teacherId", value: userData.teacherId);
      CacheHelper.saveData(key: "fullName", value: userData.fullName);
      CacheHelper.saveData(key: "phoneNumber", value: userData.phoneNumber);
      CacheHelper.saveData(key: "userId", value: userData.userId);

      CacheHelper.saveData(key: "token", value: userData.token);
      CacheHelper.saveData(key: "roles", value: userData.roles);
      CacheHelper.saveData(key: "email", value: userData.email);
      print(
          "_____________________________________________IsStudentHasParent=${CacheHelper.getData(key: "studentHasParent")}");

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
                  Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.black87.withOpacity(0.7),
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      defaultTextButton(
                        underline: true,
                        function: () {
                          navigateTo(
                            context,
                            RegisterScreen(),
                          );
                        },
                        fontSize: 16,
                        text: 'Register',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  defaultFormField(
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    validate: (String value) {
                      if (value.isEmpty) {
                        return 'please enter your email address';
                      }
                    },
                    label: 'Email Address',
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
                    isPassword: showPassword,
                    suffixPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    validate: (String value) {
                      if (value.isEmpty) {
                        return 'password is too short';
                      }
                    },
                    label: 'Password',
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
                      fontSize: 16,
                      text: 'Forgot Password?',
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
                          text: 'Login',
                          isUpperCase: false,
                        ),
                  SizedBox(
                    height: 15.0,
                  ),

                  // FutureBuilder(
                  //   future: PackageInfo.fromPlatform(),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<PackageInfo> snapshot) {
                  //     if (snapshot.hasData)
                  //       return Column(
                  //         children: [
                  //           Text(snapshot.data.appName),
                  //           Text(snapshot.data.packageName),
                  //           Text(snapshot.data.buildNumber),
                  //           Text(snapshot.data.version),
                  //         ],
                  //       ); // Column
                  //     return Container();
                  //   },
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
