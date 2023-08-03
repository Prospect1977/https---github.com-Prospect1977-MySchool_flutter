import 'dart:ui';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_school/cubits/main_cubit.dart';
import 'package:my_school/screens/changeLanguageScreen.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/parents_landing_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
void navigateAndFinish(
  context,
  widget,
) =>
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) {
        return false;
      },
    );
var AppBarActions = [
  PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onSelected: (SelectedValue) => {print(SelectedValue)},
      itemBuilder: (ctx) => [
            PopupMenuItem(
              child: Text('Home'),
              value: 0,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                var roles = CacheHelper.getData(key: "roles");
                if (roles == "Teacher") {
                  navigateTo(ctx, TeacherDashboardScreen());
                }
                if (roles == "Parent") {
                  navigateAndFinish(ctx, ParentsLandingScreen());
                }
                if (roles == "Student") {
                  navigateTo(ctx, StudentDashboardScreen());
                }
              },
            ),
            PopupMenuItem(
              child: Text('Change Language'),
              value: 1,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();

                navigateTo(ctx, ChangeLanguageScreen());
              },
            ),
            PopupMenuItem(
              child: Text('Log Out'),
              value: 2,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("token");
                await prefs.remove("roles");
                await prefs.remove("userId");

                navigateAndFinish(ctx, LoginScreen());
              },
            ),
          ]),
];
Widget appBarComponent(context, String title, {backButtonPage}) {
  return AppBar(
      elevation: 3,
      backgroundColor: interfaceColor,
      title: Center(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: backButtonPage == null
          ? null
          : IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: backButtonPage == null
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : () {
                      navigateAndFinish(context, backButtonPage);
                    },
            ),
      actions: AppBarActions);
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size(double.maxFinite, 80);
}

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.purple,
  Color foregroundColor = Colors.white,
  bool isUpperCase = false,
  double borderRadius = 3.0,
  double fontSize = 18,
  FontWeight fontWeight = FontWeight.normal,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: foregroundColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        color: background,
      ),
    );

Widget defaultTextButton({
  @required Function function,
  @required String text,
  bool isUpperCase = false,
  double fontSize = 14.1,
  Color color = defaultColor,
  bool underline = false,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    TextButton(
      onPressed: function,
      child: Text(
        isUpperCase ? text.toUpperCase() : text,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            decoration:
                underline ? TextDecoration.underline : TextDecoration.none),
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 3)),
    );

Widget defaultFormField(
        {@required TextEditingController controller,
        @required TextInputType type,
        Function onSubmit,
        Function onChange,
        Function onTap,
        bool isPassword = false,
        Function validate,
        @required String label,
        IconData prefix,
        IconData suffix,
        Function suffixPressed,
        bool isClickable = true,
        dynamic defaultValue,
        int maximumLines}) =>
    TextFormField(
      maxLines: maximumLines == null ? 1 : maximumLines,
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      initialValue: defaultValue,
      onTap: onTap,
      validator: validate != null ? validate : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix != null
            ? Icon(
                prefix,
              )
            : null,
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );

void showToast({
  @required String text,
  @required ToastStates state,
}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}
