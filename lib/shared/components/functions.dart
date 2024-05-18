import 'package:flutter/material.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/login_screen.dart';
import '../../screens/parents_landing_screen.dart';
import '../../screens/studentDashboard_screen.dart';
import '../../screens/teacher_dashboard_screen.dart';
import '../dio_helper.dart';

String ConvertNumberToHindi(String number) {
  Map numbers = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '٤',
    '5': '۵',
    '6': '٦',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };

  numbers.forEach((key, value) => number = number.replaceAll(key, value));

  return number;
}

void handleSessionExpired(context) {
  var lang = CacheHelper.getData(key: 'lang');
  var message = lang.ToLower() == "en"
      ? "Session Expired, please sign in again"
      : "من فضلك قم بتسجيل الدخول";
  showToast(text: message, state: ToastStates.WARNING);
  Navigator.of(context).pop();
  navigateAndFinish(context, LoginScreen());
}

void checkAppVersion() async {
  String appVersion;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appVersion = packageInfo.version;
  var currentRoles = CacheHelper.getData(key: 'roles');
  await DioHelper.getData(url: 'General/GetLatestVersion', query: {})
      .then((value) {
    var requiredForRoles = value.data["roles"];

    if (requiredForRoles == "All" || currentRoles == null) {
      if (value.data['androidVersion'] == appVersion ||
          value.data['macVersion'] == appVersion) {
        CacheHelper.saveData(key: 'isLatestVersion', value: true);
      } else {
        CacheHelper.saveData(key: 'isLatestVersion', value: false);
      }
    } else {
      //المكتوب في السطور التالية من المفترض بناءاً على ان اليوسر له اكثر من رول ولكن نظراً لانه لا توجد وسيلة للخروج من الفانكشن في المنتصف أو الذهاب لسطر كود محدد، فأن المكتوب يفترض أن اليوسر له رول واحد
      requiredForRoles.split(",").forEach((m) {
        if (currentRoles.contains(m)) {
          if (value.data['androidVersion'] == appVersion ||
              value.data['macVersion'] == appVersion) {
            CacheHelper.saveData(key: 'isLatestVersion', value: true);
          } else {
            CacheHelper.saveData(key: 'isLatestVersion', value: false);
          }
        } else {
          CacheHelper.saveData(key: 'isLatestVersion', value: true);
        }
      });
    }
    if (requiredForRoles.toString().toLowerCase() == "none") {
      CacheHelper.saveData(key: 'isLatestVersion', value: true);
    }
  });
}

getHomeScreen() {
  // return LoginScreen();
  var roles = CacheHelper.getData(key: "roles");
  if (roles.contains("Teacher")) {
    return TeacherDashboardScreen();
  }
  if (roles.contains("Parent")) {
    return ParentsLandingScreen();
  }
  if (roles.contains("Student")) {
    return StudentDashboardScreen();
  }
  if (roles.contains("Owner")) {
    return LoginScreen();
  }
}

int getMonthDays(int month, int year) {
  switch (month) {
    case 1:
      return 31;
      break;
    case 2:
      return year % 4 == 0 ? 28 : 29;
      break;
    case 3:
      return 31;
      break;
    case 4:
      return 30;
      break;
    case 5:
      return 31;
      break;
    case 6:
      return 30;
      break;
    case 7:
      return 31;
      break;
    case 8:
      return 31;
      break;
    case 9:
      return 30;
      break;
    case 10:
      return 31;
      break;
    case 11:
      return 30;
      break;
    case 12:
      return 31;
      break;
  }
}

String getMonthName(int month, String lang) {
  switch (month) {
    case 1:
      return lang == "en" ? "Jan." : "يناير";
      break;
    case 2:
      return lang == "en" ? "Feb." : "فبراير";
      break;
    case 3:
      return lang == "en" ? "Mars." : "مارس";
      break;
    case 4:
      return lang == "en" ? "Apr." : "إبريل";
      break;
    case 5:
      return lang == "en" ? "May." : "مايو";
      break;
    case 6:
      return lang == "en" ? "Jun." : "يونيو";
      break;
    case 7:
      return lang == "en" ? "Jul." : "يوليو";
      break;
    case 8:
      return lang == "en" ? "Aug." : "أغسطس";
      break;
    case 9:
      return lang == "en" ? "Sep." : "سبتمبر";
      break;
    case 10:
      return lang == "en" ? "Oct." : "أكتوبر";
      break;
    case 11:
      return lang == "en" ? "Nov." : "نوفمبر";
      break;
    case 12:
      return lang == "en" ? "Dec." : "ديسمبر";
      break;
  }
}

String getDayName(int day, String lang) {
  switch (day) {
    case 7:
      return lang == "en" ? "Sun." : "الأحد";
      break;
    case 1:
      return lang == "en" ? "Mon." : "الأثنين";
      break;
    case 2:
      return lang == "en" ? "Tue." : "الثلاثاء";
      break;
    case 3:
      return lang == "en" ? "Wed." : "الأربعاء";
      break;
    case 4:
      return lang == "en" ? "Thu." : "الخميس";
      break;
    case 5:
      return lang == "en" ? "Fri." : "الجمعة";
      break;
    case 6:
      return lang == "en" ? "Sat." : "السبت";
      break;
  }
}

int weekDaySundayBased(int weekDay) {
  if (weekDay == 7) {
    return 0;
  } else {
    return weekDay;
  }
}

String formatDate(DateTime dataDate, lang) {
  if (lang == "en") {
    return '${getDayName(dataDate.weekday, lang)} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}';
  } else {
    return '${getDayName(dataDate.weekday, lang)} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}';
  }
}

String QuestionType({String type, String dir}) {
  String out = "";

  switch (type) {
    case "MultipleChoice":
      out = dir == "ltr" ? "Multiple Choice" : "إختيار من متعدد";
      break;
    case "YesNo":
      out = dir == "ltr" ? "True/False" : "نعم/لا";
      break;
    case "Example":
      out = dir == "ltr" ? "Complete" : "أكمل";
      break;
  }
  return (out);
}
