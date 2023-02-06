import 'package:flutter/cupertino.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentVideoProvider with ChangeNotifier {}

var lang = CacheHelper.getData(key: "lang");
var token = CacheHelper.getData(key: "token");
void saveProgress(
  context,
  int StudentId,
  int VideoId,
  int CurrentSecond,
) {
  DioHelper.postData(
      url: 'StudentUpdateVideoProgress',
      query: {},
      lang: lang,
      token: token,
      data: {
        "StudentId": StudentId,
        "VideoId": VideoId,
        "CurrentSecond": CurrentSecond,
        "DataDate": DateTime.now(),
      }).then((value) {
    print(value.data);
    if (value.data["status"] == true) {
      showToast(
          text: lang == "en" ? "Saved Successfully!" : "تم حفظ الإعدادات بنجاح",
          state: ToastStates.SUCCESS);
    } else {
      showToast(
          text: lang == "en" ? "Something went wrong!" : "حدث خطأ ما!",
          state: ToastStates.ERROR);
      navigateAndFinish(context, LoginScreen());
    }
  }).catchError((error) {
    print(error.toString());
  });
}
