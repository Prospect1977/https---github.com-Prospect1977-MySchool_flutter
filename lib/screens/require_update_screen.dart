import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restart_app/restart_app.dart';

class RequireUpdateScreen extends StatefulWidget {
  const RequireUpdateScreen({Key key}) : super(key: key);

  @override
  State<RequireUpdateScreen> createState() => _RequireUpdateScreenState();
}

class _RequireUpdateScreenState extends State<RequireUpdateScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  var url =
      'https://play.google.com/store/apps/details?id=com.digischool.my_school&pli=1';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("I am opened now!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/logo.png'),
          Text(
            lang == "en"
                ? "This app. version is outdated, update in order to continue"
                : "هذا الإصدار من التطبيق قديم! برجاء تحديث التطبيق للمتابعة",
            style: TextStyle(
              fontSize: 24,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: defaultButton(
                fontSize: 22,
                function: () {
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                  //  Restart.restartApp();
                  navigateTo(context, getHomeScreen());
                },
                text: lang == "en" ? "Update" : "تحديث"),
          ),
        ]),
      ),
    ));
  }
}
