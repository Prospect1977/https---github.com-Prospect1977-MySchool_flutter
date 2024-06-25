import 'package:flutter/cupertino.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../shared/components/constants.dart';

class StudentVideoProvider with ChangeNotifier {}

var lang = CacheHelper.getData(key: "lang");
var token = CacheHelper.getData(key: "token");
void saveProgress(
  context,
  int StudentId,
  int VideoId,
  int CurrentSecond,
) async {
  var url = Uri.parse(
    '${baseUrl}StudentUpdateVideoProgress?StudentId=$StudentId&VideoId=$VideoId&CurrentSecond=$CurrentSecond&DataDate=${DateTime.now()}',
  );
  final response = await http.post(url, headers: {
    "lang": lang,
    'Authorization': 'Bearer $token',
    'Content-type': 'application/json',
    'Accept': 'application/json',
  }, body: {
    "StudentId": StudentId,
    "VideoId": VideoId,
    "CurrentSecond": CurrentSecond,
    "DataDate": DateTime.now(),
  });
  final value = json.decode(response.body);

  if (value["status"] == false && value["message"] == "SessionExpired") {
    handleSessionExpired(context);
    return;
  } else if (value["status"] == false) {
    showToast(text: value["message"], state: ToastStates.ERROR);
    return;
  }
  if (value["status"] == true) {
    showToast(
        text: lang == "en" ? "Saved Successfully!" : "تم حفظ الإعدادات بنجاح",
        state: ToastStates.SUCCESS);
  } else {
    showToast(
        text: lang == "en" ? "Something went wrong!" : "حدث خطأ ما!",
        state: ToastStates.ERROR);
  }
}
