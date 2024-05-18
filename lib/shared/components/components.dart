import 'dart:ui';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_school/cubits/main_cubit.dart';
import 'package:my_school/models/teacher-payment-type-model.dart';
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
      iconSize: 30,
      icon: CircleAvatar(
        backgroundColor: Colors.black38,
        child: Icon(
          Icons.more_vert,
          size: 20,
          color: Colors.white,
        ),
      ),
      onSelected: (SelectedValue) => {print(SelectedValue)},
      itemBuilder: (ctx) => [
            PopupMenuItem(
              child: Text('Home'),
              value: 0,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                var roles = CacheHelper.getData(key: "roles");
                if (roles.contains("Teacher")) {
                  navigateTo(ctx, TeacherDashboardScreen());
                }
                if (roles.contains("Parent")) {
                  navigateAndFinish(ctx, ParentsLandingScreen());
                }
                if (roles.contains("Student")) {
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

// class appBarComponent extends StatelessWidget implements PreferredSizeWidget {
//   appBarComponent(context, this.title, {this.backButtonPage, Key key})
//       : super(key: key);
//   final String title;
//   Widget backButtonPage;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         margin: EdgeInsets.only(top: 5, left: 8, right: 8),
//         child:
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5),
//               child: CircleAvatar(
//                 radius: 15,
//                 backgroundColor: Colors.black38,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 0),
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back_ios_rounded),
//                     iconSize: 15,
//                     onPressed: backButtonPage == null
//                         ? () {
//                             Navigator.maybePop(context);
//                           }
//                         : () {
//                             navigateAndFinish(context, backButtonPage);
//                           },
//                     color: Colors.white,
//                   ),
//                 ),
//               )),
//           Expanded(
//             child: Container(
//               height: 30,
//               // padding: EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 color: Colors.black26,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(width: 45, height: 45, child: AppBarActions[0])
//         ]),
//       ),
//     );
//   }
class appBarComponent extends StatelessWidget implements PreferredSizeWidget {
  appBarComponent(context, this.title, {this.backButtonPage, Key key})
      : super(key: key);
  final String title;
  Widget backButtonPage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 5, left: 8, right: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    iconSize: 15,
                    onPressed: backButtonPage == null
                        ? () {
                            Navigator.maybePop(context);
                          }
                        : () {
                            navigateAndFinish(context, backButtonPage);
                          },
                    color: Colors.white,
                  ),
                ),
              )),
          Expanded(
            child: Container(
              height: 30,
              // padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.black26,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 45, height: 45, child: AppBarActions[0])
        ]),
      ),
    );
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
      color = Colors.amber.shade700;
      break;
  }

  return color;
}

class dropDownTransferAccountType extends StatelessWidget {
  dropDownTransferAccountType({
    @required this.lang,
    @required this.TransferTypes,
    @required this.onChanged,
    @required this.selectedItem,
  });
  final List<TeacherPaymentTransferType> TransferTypes;
  final String lang;
  final Function onChanged;
  final int selectedItem;

  List<DropdownMenuItem> menuItems = [];

  @override
  Widget build(BuildContext context) {
    TransferTypes.forEach(
      (sc) {
        menuItems.add(
          DropdownMenuItem(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white))),
              alignment:
                  lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(
                lang == "en" ? sc.nameEng : sc.nameAra,
              ),
            ),
            value: sc.id,
          ),
        );
      },
    );

    return Directionality(
      textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonFormField(
          // key: ValueKey(1),

          value: selectedItem == null ? 0 : selectedItem,
          validator: (value) => value == 0
              ? (lang == "ar" ? 'هذا الحقل مطلوب' : 'This field is required')
              : null,
          items: [
            //add items in the dropdown
            DropdownMenuItem(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white))),
                alignment:
                    lang == "en" ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  lang == "en"
                      ? "Select a method to transfer profit"
                      : "إختر طريقة تحويل الأرباح",
                ),
              ),
              value: 0,
            ),
            ...menuItems,
          ],

          onChanged: (value) {
            onChanged(value);
          },

          icon: Padding(
              //Icon at tail, arrow bottom is default icon
              padding: EdgeInsets.all(0),
              child: Icon(Icons.keyboard_arrow_down)),
          iconEnabledColor: Colors.black54, //Icon color
          style: TextStyle(
              //te
              color: Colors.black87, //Font color
              fontSize: 16 //font size on dropdown button
              ),
          decoration: InputDecoration(border: InputBorder.none),

          dropdownColor: Colors.white, //dropdown background color
          //remove underline
          isExpanded: true, //make true to make width 100%
        ),
      ),
    );
  }
}
