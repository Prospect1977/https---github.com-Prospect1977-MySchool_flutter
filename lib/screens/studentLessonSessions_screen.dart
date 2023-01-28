import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentLessonSessions_cubit.dart';
import 'package:my_school/cubits/StudentLessonSessions_states.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

class StudentLessonSessionsScreen extends StatefulWidget {
  final int studentId;
  final int lessonId;
  final String lessonName;
  final int YearSubjectId;

  StudentLessonSessionsScreen(
      this.studentId, this.lessonId, this.lessonName, this.YearSubjectId,
      {Key key})
      : super(key: key);

  @override
  var showLessons = false;
  State<StudentLessonSessionsScreen> createState() =>
      _StudentLessonSessionsScreenState();
}

class _StudentLessonSessionsScreenState
    extends State<StudentLessonSessionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, widget.lessonName),
      body: BlocProvider(
        create: (context) => StudentLessonSessionsCubit()
          ..getSessions(widget.studentId, widget.lessonId)
          ..getLessons(widget.studentId, widget.YearSubjectId),
        child: BlocConsumer<StudentLessonSessionsCubit,
            StudentLessonSessionsStates>(
          listener: (context, state) {
            if (state is UnAuthendicatedState) {
              navigateAndFinish(context, LoginScreen());
            }
          },
          builder: (context, state) {
            var cubit = StudentLessonSessionsCubit.get(context);

            return cubit.StudentLessonSessionCollection == null
                ? Center(child: CircularProgressIndicator())
                : widget.showLessons == false
                    ?
                    //------------------------------------- Teachers
                    Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: cubit
                                        .StudentLessonSessionCollection
                                        .items
                                        .length,
                                    itemBuilder: (context, index) {
                                      var item = cubit
                                          .StudentLessonSessionCollection
                                          .items[index];
                                      return Text(item.teacherName);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            child: Image.asset(
                              "assets/images/expand_right.png",
                              width: 25,
                              height: 50,
                              opacity: AlwaysStoppedAnimation(1),
                            ),
                            onTap: () {
                              setState(() {
                                widget.showLessons = true;
                                print(widget.showLessons);
                              });
                            },
                          ),
                        ],
                      )
                    :
                    //-----------------------------------------------------------Lessons
                    Center(
                        child: CircularProgressIndicator(),
                      );
          },
        ),
      ),
    );
  }
}
