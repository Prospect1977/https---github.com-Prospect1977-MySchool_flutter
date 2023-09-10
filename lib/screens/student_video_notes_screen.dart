import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/student_video_notes_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/studentStudyBySubject_navigation_bar.dart';

import '../shared/components/constants.dart';

class StudentVideoNotesScreen extends StatefulWidget {
  const StudentVideoNotesScreen(
      {@required this.studentId,
      @required this.YearSubjectId,
      @required this.SubjectName,
      @required this.dir,
      Key key})
      : super(key: key);
  final int studentId;

  final int YearSubjectId;
  final String SubjectName;
  final String dir;

  @override
  State<StudentVideoNotesScreen> createState() =>
      _StudentVideoNotesScreenState();
}

class _StudentVideoNotesScreenState extends State<StudentVideoNotesScreen> {
  StudentVideoNotesModel model;
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  void getData() {
    setState(() {
      model = null;
    });

    DioHelper.getData(
            url: 'StudentVideoNotes',
            query: {
              'StudentId': widget.studentId,
              'YearSubjectId': widget.YearSubjectId
            },
            lang: lang,
            token: token)
        .then((value) {
      print(
          "--------------------------------------------------------------${value.data["data"]}");
      if (value.data["status"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      setState(() {
        model = StudentVideoNotesModel.fromJson(value.data["data"]);
      });
    }).catchError((error) {
      print(error.toString());
      showToast(
          text: lang == "en" ? "Unkown error occured!" : "حدث خطأ ما!",
          state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print("---------------YearSubjectId:${widget.YearSubjectId}");
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, widget.SubjectName),
        bottomNavigationBar: StudentStudyBySubjectNavigationBar(
          PageIndex: 1,
          StudentId: widget.studentId,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: model == null
              ? Center(child: CircularProgressIndicator())
              : Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          Divider(thickness: 0.5),
                      itemCount: model.Notes.length,
                      itemBuilder: (context, index) {
                        var item = model.Notes[index];
                        return InkWell(
                            onTap: () {
                              navigateTo(
                                  context,
                                  VideoScreen(
                                    StudentId: widget.studentId,
                                    VideoId: item.videoId,
                                    VideoUrl: item.videoUrl,
                                    aspectRatio: item.aspectRatio,
                                    UrlSource: item.urlSource,
                                    Title: item.title,
                                    LessonName: item.lessonName,
                                    LessonDescription: item.lessonName,
                                    CoverUrl: item.coverUrlSource == "web" ||
                                            item.coverUrlSource == "Web"
                                        ? "${webUrl}Sessions/VideoCovers/${item.coverUrl}"
                                        : "${baseUrl0}Sessions/VideoCovers/${item.coverUrl}",
                                    dir: widget.dir,
                                    TeacherName: item.teacherName,
                                    VideoName: item.videoName,
                                    GoToSecond: item.goToSecond,
                                  ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.lessonName,
                                  style: TextStyle(
                                      color: defaultColor, fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(item.note,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black54,
                                            fontSize: 17)),
                                  ],
                                )
                              ],
                            ));
                      },
                    ),
                  ),
                ),
        ));
  }
}
