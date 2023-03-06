import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_school/shared/styles/colors.dart';

Widget dashboardButton(context, onClick, imageName, title, isDisabled) {
  return InkWell(
    onTap: onClick,
    child: Card(
      elevation: 0,
      // margin: EdgeInsets.only(horizontal: 10, vertical: 10),
      color: Color.fromARGB(255, 250, 250, 250),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDisabled
                  ? Colors.black.withOpacity(0.3)
                  : defaultColor.withOpacity(.4)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width / 5.5,
            height: MediaQuery.of(context).size.width / 5.5,
            child: Image.asset(
              'assets/images/$imageName',
            ),
          )),
          Container(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 15,
                  color: isDisabled ? Colors.black38 : defaultColor),
              textAlign: TextAlign.center,
            ),
          )
        ]),
      ),
    ),
  );
}
