import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/components/components.dart';

class StudentLessonDetailsScreen extends StatelessWidget {
  final int lessonId;
  final String lessonName;
  const StudentLessonDetailsScreen(this.lessonId, this.lessonName, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, lessonName),
        body: Center(
          child: CircularProgressIndicator(),
        ));
  }
}
