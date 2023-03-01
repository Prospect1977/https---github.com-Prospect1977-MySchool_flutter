import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_school/shared/cache_helper.dart';

class DateFilterTitleWidget extends StatelessWidget {
  DateFilterTitleWidget({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;
  final String lang = CacheHelper.getData(key: "lang");

  @override
  Widget build(BuildContext context) {
    return Container(
      height: lang == "en" ? 30 : 33,
      width: double.infinity,
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.9)),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
