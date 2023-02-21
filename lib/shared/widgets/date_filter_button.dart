import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';

class DateFilterButton extends StatelessWidget {
  final bool active;
  final String caption;
  final DateTime fromDate;
  final DateTime toDate;
  final String filterBy;
  Function(DateTime, DateTime, String) onClick;
  DateFilterButton(
      {@required this.caption,
      @required this.active,
      @required this.onClick,
      @required this.fromDate,
      @required this.toDate,
      @required this.filterBy});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return ElevatedButton(
        onPressed: () => onClick(fromDate, toDate, filterBy),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            textStyle: TextStyle(fontSize: 12)),
        child: Text(caption),
      );
    } else {
      return TextButton(
        onPressed: () => onClick(fromDate, toDate, filterBy),
        style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 12),
            foregroundColor: Color.fromARGB(255, 94, 94, 94)),
        child: Text(caption),
      );
    }
  }
}
