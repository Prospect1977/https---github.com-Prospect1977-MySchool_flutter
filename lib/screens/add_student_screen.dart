import 'package:flutter/material.dart';

import 'package:my_school/cubits/login_cubit.dart';
import 'package:my_school/models/login_model.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/studentProfile_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';

import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  var formKey = GlobalKey<FormState>();
  var lang = CacheHelper.getData(key: "lang");
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();

  var accountType = "Parent";
  bool showPassword = false;
  String token = CacheHelper.getData(key: "token");
  void sendForm() async {
    //if (formKey.currentState.validate()) {
    DioHelper.postDataForLogin(
        url: "Account/AddStudent?DataDate=${DateTime.now()}",
        token: token,
        data: {
          "email": emailController.text,
          "password": passwordController.text,
          "FullName": fullNameController.text,
          "PhoneNumber": "000",
          "Role": "Student",
        }).then((value) {
      print(value.data["data"]);
      int StudentId = value.data["data"];
      print(StudentId);
      navigateTo(
          context,
          StudentProfileScreen(
            StudentId,
            FullName: fullNameController.text,
          ));
    }).catchError((error) {
      print(error.toString());
      showToast(
          text: lang == "en"
              ? "The email is either used before or incorrect format!"
              : "البريد الإلكتروني غير مكتوب بشكل صحيح أو تم تسجيله من قبل!",
          state: ToastStates.ERROR);
    });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            appBarComponent(context, lang == "en" ? "Register" : "حساب جديد"),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Directionality(
                    textDirection:
                        lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                    child: defaultFormField(
                      controller: fullNameController,
                      type: TextInputType.text,
                      prefix: Icons.account_circle_rounded,
                      validate: (String value) {
                        if (value.isEmpty || value.split(" ").length < 2) {
                          return lang == "en"
                              ? 'please enter your Full Name'
                              : "من فضلك ادخل الإسم بالكامل";
                        }
                      },
                      label: lang == "en" ? 'Full Name' : "الإسم بالكامل",
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  defaultFormField(
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'please enter your email address'
                            : "من فضلك ادخل البريد الإلكتروني";
                      }
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
                    suffix: showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSubmit: (value) {
                      if (formKey.currentState.validate()) {
                        // sendForm();
                      }
                    },
                    isPassword: !showPassword,
                    suffixPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'Please select a password'
                            : "اختر كلمة المرور";
                      }
                      if (value.length < 8) {
                        return lang == "en"
                            ? 'Password must be at least 8 characters long!'
                            : "كلمة المرور لا يجب أن تقل عن 8 احرف";
                      }
                    },
                    label: lang == "en" ? 'Password' : "كلمة المرور",
                    prefix: Icons.lock_outline,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  defaultFormField(
                    controller: confirmPasswordController,
                    type: TextInputType.visiblePassword,
                    suffix: showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSubmit: (value) {
                      if (formKey.currentState.validate()) {
                        sendForm();
                      }
                    },
                    isPassword: !showPassword,
                    suffixPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'Please confirm password'
                            : "من فضلك اكًد كلمة المرور";
                      }
                      if (value != passwordController.text) {
                        return 'Password not match';
                      }
                    },
                    label:
                        lang == "en" ? 'Confirm Password' : "تأكيد كلمة المرور",
                    prefix: Icons.lock_outline,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  defaultButton(
                      function: () {
                        if (formKey.currentState.validate()) {
                          sendForm();
                        }
                      },
                      text: lang == "en" ? "Add" : "إضافة")
                ],
              ),
            ),
          ),
        ));
  }
}
