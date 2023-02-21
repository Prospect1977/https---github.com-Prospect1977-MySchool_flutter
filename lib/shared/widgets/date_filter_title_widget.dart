import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateFilterTitleWidget extends StatelessWidget {
  const DateFilterTitleWidget({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
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
