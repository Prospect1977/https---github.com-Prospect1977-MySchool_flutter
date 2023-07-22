import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var emailController = TextEditingController();
  bool isLoading = false;
  bool isSucceeded = false;
  bool isFailure = false;
  void sendData() {
    setState(() {
      isLoading = true;
    });
    DioHelper.postData(
        url: 'Account/forgotPassword',
        query: {"Email": emailController.text}).then((value) {
      // bool status = value.data["status"];
      //print(status);
      setState(() {
        isLoading = false;

        isSucceeded = true;
        isFailure = false;
      });
    }).catchError((error) {
      print(error.toString());
      setState(() {
        isLoading = false;

        isSucceeded = false;
        isFailure = true;
      });
      showToast(text: "Unkown error occured!", state: ToastStates.ERROR);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, "Forgot Password"),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            isSucceeded
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "An email has been sent to '${emailController.text}', Please open the sent mail to reset your password!",
                      style:
                          TextStyle(color: Colors.green.shade900, fontSize: 16),
                    ),
                  )
                : Container(),
            isFailure
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(
                            color: Colors.red.shade900.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "This email has no registered account",
                      style:
                          TextStyle(color: Colors.red.shade900, fontSize: 16),
                    ),
                  )
                : Container(),
            isSucceeded || isFailure
                ? SizedBox(
                    height: 15.0,
                  )
                : Container(),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : isSucceeded
                    ? defaultButton(
                        function: () {
                          navigateAndFinish(context, LoginScreen());
                        },
                        borderRadius: 5,
                        text: 'Login',
                        isUpperCase: false,
                      )
                    : defaultButton(
                        function: () {
                          sendData();
                        },
                        borderRadius: 5,
                        text: 'Submit',
                        isUpperCase: false,
                      )
          ],
        ),
      ),
    );
  }
}
