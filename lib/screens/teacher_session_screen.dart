import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/components/components.dart';

class TeacherSessionScreen extends StatefulWidget {
  int TeacherId;
  int YearSubjectId;
  int TermIndex;
  int LessonId;
  String LessonName;
  String dir;
  TeacherSessionScreen(
      {@required this.TeacherId,
      @required this.YearSubjectId,
      @required this.TermIndex,
      @required this.LessonId,
      @required this.LessonName,
      @required this.dir,
      Key key})
      : super(key: key);

  @override
  State<TeacherSessionScreen> createState() => _TeacherSessionScreenState();
}

class _TeacherSessionScreenState extends State<TeacherSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, widget.LessonName),
      body: Container(),
    );
  }
}
