import 'package:flutter/material.dart';

import 'package:my_school/cubits/login_cubit.dart';
import 'package:my_school/models/login_model.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/studentProfile_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/screens/teacher_profile_screen.dart';

import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();
  var lang = CacheHelper.getData(key: "lang");
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var nationalIdController = TextEditingController();
  var accountType = "Parent";
  bool showPassword = false;
  void sendForm() async {
    FocusScope.of(context).unfocus();
    DioHelper.postDataForLogin(
        url: "Account/Register?DataDate=${DateTime.now()}",
        data: {
          "email": emailController.text,
          "password": passwordController.text,
          "FullName": fullNameController.text,
          "PhoneNumber": phoneNumberController.text,
          "NationalId": nationalIdController.text,
          "Role": accountType,
        }).then((value) {
      print(value.data);
      UserData userData = UserData.fromJson(value.data);
      CacheHelper.saveData(key: "token", value: userData.token);
      CacheHelper.saveData(key: "roles", value: userData.roles);
      CacheHelper.saveData(key: "fullName", value: userData.fullName);
      CacheHelper.saveData(key: "email", value: userData.email);
      CacheHelper.saveData(key: "userId", value: userData.userId);
      if (userData.roles.contains("Parent")) {
        navigateAndFinish(context, ParentsLandingScreen());
      }
      if (userData.roles.contains("Student")) {
        CacheHelper.putBoolean(
            key: "isStudentHasParent", value: userData.isStudentHasParent);
        CacheHelper.saveData(key: "studentId", value: userData.studentId);

        navigateAndFinish(
            context,
            StudentProfileScreen(userData.studentId,
                FullName: userData.fullName)); //teacherid is not a mistake
      }
      if (userData.roles.contains("Teacher")) {
        CacheHelper.saveData(key: "teacherId", value: userData.teacherId);
        navigateAndFinish(
            context,
            TeacherProfileScreen(
              teacherId: userData.teacherId,
              readOnly: false,
            ));
      }
    }).catchError((error) {
      print(error.toString());
      showToast(
          text: lang == "en"
              ? "The email is either used before or incorrect format!"
              : "البريد الإلكتروني غير مكتوب بشكل صحيح أو تم تسجيله من قبل!",
          state: ToastStates.ERROR);
    });
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                accountType = "Parent";
                              });
                            },
                            child: AccountTypeItem(
                              accountType: "Parent",
                              currentAccountType: accountType,
                              imageName: "parent.png",
                              imageNameDisabled: "parent-bw.png",
                              title: lang == "en" ? "Parent" : "ولي أمر",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                accountType = "Student";
                              });
                            },
                            child: AccountTypeItem(
                              accountType: "Student",
                              currentAccountType: accountType,
                              imageName: "student3d.png",
                              imageNameDisabled: "student3d-bw.png",
                              title: lang == "en" ? "Student" : "طالب",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                accountType = "Teacher";
                              });
                            },
                            child: AccountTypeItem(
                              accountType: "Teacher",
                              currentAccountType: accountType,
                              imageName: "teacher.png",
                              imageNameDisabled: "teacher-bw.png",
                              title: lang == "en" ? "Teacher" : "مُعلم",
                            ),
                          ),
                        ],
                      )),
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
                    controller: phoneNumberController,
                    type: TextInputType.number,
                    prefix: Icons.phone_android,
                    validate: (String value) {
                      if (value.isEmpty) {
                        return lang == "en"
                            ? 'please enter your Phone Number'
                            : "من فضلك ادخل رقم الهاتف";
                      }
                    },
                    label: lang == "en" ? 'Phone Number' : "رقم الهاتف",
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
                  accountType == "Teacher"
                      ? SizedBox(
                          height: 15.0,
                        )
                      : Container(),
                  accountType == "Teacher"
                      ? defaultFormField(
                          controller: nationalIdController,
                          type: TextInputType.number,
                          validate: (String value) {
                            if (accountType == "Teacher" && value.isEmpty) {
                              return lang == "en"
                                  ? 'please enter your National ID'
                                  : "من فضلك ادخل الرقم القومي";
                            }
                          },
                          label: lang == "en" ? 'National ID' : "الرقم القومي",
                          prefix: Icons.credit_card,
                        )
                      : Container(),
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
                      text: lang == "en" ? "Register" : "إنشاء الحساب")
                ],
              ),
            ),
          ),
        ));
  }
}

class AccountTypeItem extends StatelessWidget {
  const AccountTypeItem({
    Key key,
    @required this.accountType,
    @required this.currentAccountType,
    @required this.title,
    @required this.imageName,
    @required this.imageNameDisabled,
  }) : super(key: key);

  final String accountType;
  final String currentAccountType;
  final String title;
  final String imageName;
  final String imageNameDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(
                  color: currentAccountType == accountType
                      ? interfaceColor
                      : Colors.black26)),
          child: Image.asset(
            currentAccountType == accountType
                ? "assets/images/$imageName"
                : "assets/images/$imageNameDisabled",
            height: 100,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: TextStyle(
              fontSize: 16,
              color: currentAccountType == accountType
                  ? Colors.deepPurple
                  : Colors.black54),
        )
      ]),
    );
  }
}
