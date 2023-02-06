import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:my_school/providers/StudentLessonSessions_provider.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/on_boarding_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/bloc_observer.dart';
import 'package:my_school/cubits/main_cubit.dart';
import 'package:my_school/cubits/main_states.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/themes.dart';
import 'package:my_school/screens/landing_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // بيتأكد ان كل حاجه هنا في الميثود خلصت و بعدين يتفح الابلكيشن
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
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
  if (onBoarding == true) {
    if (token != null) {
      print('Current Role:$roles');
      switch (roles) {
        case "Parent":
          widget = ParentsLandingScreen();
          break;
        case "Student":
          widget = StudentDashboardScreen();
        //widget = LoginScreen();
      }

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
          // ChangeNotifierProvider.value()
          ChangeNotifierProvider.value(value: StudentLessonSessionsProvider()),
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
