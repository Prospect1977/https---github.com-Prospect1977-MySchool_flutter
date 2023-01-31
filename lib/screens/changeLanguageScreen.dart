import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/widgets/selectLanguage.dart';

class ChangeLanguageScreen extends StatefulWidget {
  ChangeLanguageScreen({Key key}) : super(key: key);

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "ar" ? "لغة التطبيق" : "App Language"),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectLanguageWidget(lange: lang),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: defaultButton(
                  function: () {
                    if (CacheHelper.getData(key: "token") != null) {
                      var roles = CacheHelper.getData(key: "roles");
                      switch (roles) {
                        case "Parent":
                          navigateAndFinish(context, ParentsLandingScreen());
                          break;
                        case "Student":
                          navigateAndFinish(context, StudentDashboardScreen());
                          break;
                      }

                      // widget = LandingScreen(); //the page after signing in
                    } else
                      navigateAndFinish(context, LoginScreen());
                  },
                  text: "OK"),
            ),
          ]),
    );
  }
}
