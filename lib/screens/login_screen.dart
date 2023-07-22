import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_school/screens/forgot_password_screen.dart';
import 'package:my_school/screens/landing_screen.dart';
import 'package:my_school/cubits/login_cubit.dart';
import 'package:my_school/cubits/login_states.dart';

import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/register_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';

class LoginScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            //if (state.loginModel.status==401) {
            // print(state.loginModel.message);
            // print(state.loginModel.data.token);
            CacheHelper.saveData(key: "roles", value: state.userModel.roles);
            CacheHelper.saveData(key: "userId", value: state.userModel.userId);

            CacheHelper.saveData(
              key: 'token',
              value: state.userModel.token,
            ).then((value) {
              print("SavedToken: ${CacheHelper.getData(key: "token")}");
              var page;
              if (state.userModel.roles.contains("Parent")) {
                page = ParentsLandingScreen();
              }
              if (state.userModel.roles.contains("Student")) {
                page = StudentDashboardScreen();
              }
              if (state.userModel.roles.contains("Teacher")) {
                page = TeacherDashboardScreen();
              }
              navigateAndFinish(
                context,
                page,
              );
            });
          } else {
            // print(state.loginModel.message);

            showToast(
              text: "Invalid Email or Password!",
              state: ToastStates.ERROR,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: appBarComponent(context, ""),
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
                          suffix: LoginCubit.get(context).suffix,
                          onSubmit: (value) {
                            if (formKey.currentState.validate()) {
                              LoginCubit.get(context).userLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          isPassword: LoginCubit.get(context).isPassword,
                          suffixPressed: () {
                            LoginCubit.get(context).changePasswordVisibility();
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
                            color: Colors.black38,
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
                        ConditionalBuilder(
                            condition: state is! LoginLoadingState,
                            builder: (context) => defaultButton(
                                  function: () {
                                    if (formKey.currentState.validate()) {
                                      LoginCubit.get(context).userLogin(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    }
                                  },
                                  borderRadius: 5,
                                  text: 'Login',
                                  isUpperCase: false,
                                ),
                            fallback: (context) {
                              if (state is LoginErrorState) {
                                return defaultButton(
                                  function: () {
                                    if (formKey.currentState.validate()) {
                                      LoginCubit.get(context).userLogin(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    }
                                  },
                                  text: 'Login',
                                  isUpperCase: false,
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
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
        },
      ),
    );
  }
}
