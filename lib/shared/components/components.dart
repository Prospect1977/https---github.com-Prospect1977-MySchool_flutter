import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_school/cubits/main_cubit.dart';
import 'package:my_school/screens/changeLanguageScreen.dart';

import 'package:my_school/screens/login_screen.dart';
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
              child: Text('Change Language'),
              value: 0,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();

                navigateTo(ctx, ChangeLanguageScreen());
              },
            ),
            PopupMenuItem(
              child: Text('Log Out'),
              value: 0,
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

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.purple,
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
            color: Colors.white,
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
  double fontSize = 14.1,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    TextButton(
      onPressed: function,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChange,
  Function onTap,
  bool isPassword = false,
  @required Function validate,
  @required String label,
  @required IconData prefix,
  IconData suffix,
  Function suffixPressed,
  bool isClickable = true,
  dynamic defaultValue,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      initialValue: defaultValue,
      onTap: onTap,
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
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
