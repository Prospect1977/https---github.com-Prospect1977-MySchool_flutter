import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:my_school/providers/QuizProvider.dart';
import 'package:my_school/providers/StudentLessonSessions_provider.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/on_boarding_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/screens/test_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/bloc_observer.dart';
import 'package:my_school/cubits/main_cubit.dart';
import 'package:my_school/cubits/main_states.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/themes.dart';

import 'package:provider/provider.dart';

import 'shared/components/functions.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  // بيتأكد ان كل حاجه هنا في الميثود خلصت و بعدين يتفح الابلكيشن
  WidgetsFlutterBinding.ensureInitialized();

  //Bloc.observer = MyBlocObserver();
  DioHelper.init();
  await CacheHelper.init();

  bool isDark = CacheHelper.getData(key: 'isDark');

  Widget widget;

  //Remove Later
  // CacheHelper.saveData(
  //   key: 'onBoarding',
  //   value: false,
  // );
  //Remove Later

  bool onBoarding = CacheHelper.getData(key: 'onBoarding');
  // bool onBoarding = false;
  String token = CacheHelper.getData(key: 'token');
  String roles = CacheHelper.getData(key: 'roles');
  await checkAppVersion();
  bool isUpdated = CacheHelper.getData(key: "isLatestVersion");
  if (isUpdated == false) {
    widget = RequireUpdateScreen();
  } else {
    if (onBoarding == true) {
      if (token != null) {
        print('Current Role:$roles');

        widget = getHomeScreen();
        // widget = LandingScreen(); //the page after signing in
      } else {
        widget = LoginScreen();
        // widget = VideoScreen(
        //   StudentId: 1013,
        //   Title: 'dsff0',
        //   VideoId: 1,
        //   VideoUrl: "dsfsf",
        // );
      }
    } else {
      widget = OnBoardingScreen();
    }
  }

  // widget = TestScreen();
  runApp(MyApp(
    isDark: isDark,
    startWidget: widget,
  ));
}

// Stateless
// Stateful

// class MyApp

class MyApp extends StatelessWidget {
  // constructor
  // build
  final bool isDark;
  final Widget startWidget;

  MyApp({
    this.isDark,
    this.startWidget,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //  ChangeNotifierProvider.value()
          ChangeNotifierProvider.value(value: StudentLessonSessionsProvider()),
          ChangeNotifierProvider.value(value: QuizProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: startWidget,
        ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
