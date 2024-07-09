import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/user/student.dart';
import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/screens/teacher_profile_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';

import '../models/student_favorite_model.dart';
import '../shared/components/constants.dart';
import '../shared/dio_helper.dart';
import '../shared/styles/colors.dart';
import '../shared/widgets/studentStudyBySubject_navigation_bar.dart';

class StudentFavoritesBySubjectScreen extends StatefulWidget {
  StudentFavoritesBySubjectScreen(
      {this.StudentId, this.YearSubjectId, this.SubjectName, this.dir, Key key})
      : super(key: key);
  int StudentId;
  int YearSubjectId;
  String dir;
  String SubjectName;
  @override
  State<StudentFavoritesBySubjectScreen> createState() =>
      _StudentFavoritesBySubjectScreenState();
}

class _StudentFavoritesBySubjectScreenState
    extends State<StudentFavoritesBySubjectScreen> {
  List<StudentFavorite> model;
  int TermIndex = 0; //0 means current term index

  void getData() {
    model = null;
    DioHelper.getData(
      url: 'StudentFavoriteSessions/GetYearSubjectFavorites',
      query: {
        'StudentId': widget.StudentId,
        'YearSubjectId': widget.YearSubjectId,
        'TermIndex': TermIndex,
      },
      lang: CacheHelper.getData(key: 'lang'),
    ).then((value) {
      print(value.data["data"]);
      setState(() {
        model = (value.data["data"] as List)
            .map((item) => StudentFavorite.fromJson(item))
            .toList();
      });
    }).catchError((error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  List<DropdownMenuItem> Terms = [];
  void getTermsIndecies() {
    Terms = [
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            widget.dir == "ltr" ? '1st Term' : 'الفصل الدراسي الأول',
          ),
        ),
        value: 1,
      ),
      DropdownMenuItem(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))),
          alignment: widget.dir == "ltr"
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Text(
            widget.dir == "ltr" ? '2nd Term' : 'الفصل الدراسي الثاني',
          ),
        ),
        value: 2,
      ),
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getTermsIndecies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(context, widget.SubjectName),
        bottomNavigationBar: StudentStudyBySubjectNavigationBar(
          PageIndex: 2,
          StudentId: widget.StudentId,
        ),
        body: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black26)),
                      child: DropdownButton(
                        //key: ValueKey(1),
                        value: TermIndex,
                        items: [
                          //add items in the dropdown
                          DropdownMenuItem(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.white))),
                              alignment: widget.dir == "ltr"
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Text(
                                widget.dir == "ltr"
                                    ? "Current Term"
                                    : "الفصل الدراسي الحالي",
                              ),
                            ),
                            value: 0,
                          ),
                          ...Terms,
                        ],

                        onChanged: (value) {
                          setState(() {
                            TermIndex = value;
                          });
                          getData();
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
                        underline: Container(),

                        dropdownColor: Colors.white, //dropdown background color
                        //remove underline
                        isExpanded: true, //make true to make width 100%
                      ),
                    ),
                    Expanded(
                      child: model.length == 0
                          ? EmptyWidget(widget.dir)
                          : ListView.builder(
                              itemCount: model.length,
                              itemBuilder: (context, index) {
                                var item = model[index];
                                return InkWell(
                                  onTap: () {
                                    navigateTo(
                                        context,
                                        StudentSessionDetailsScreen(
                                          SessionHeaderId: item.sessionHeaderId,
                                          LessonName: item.lessonName,
                                          LessonDescription:
                                              item.lessonDescription,
                                          dir: widget.dir,
                                          StudentId: widget.StudentId,
                                          TeacherName: item.teacherName,
                                        ));
                                  },
                                  child: Card(
                                    elevation: 1,
                                    child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          children: [
                                            Row(
                                                //-------------------------------------------------card row
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      navigateTo(
                                                          context,
                                                          TeacherProfileScreen(
                                                              teacherId: item
                                                                  .teacherId,
                                                              readOnly: true));
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 32,
                                                      backgroundColor:
                                                          defaultColor
                                                              .withOpacity(
                                                                  0.65),
                                                      child: CircleAvatar(
                                                        //-----------------------------------------Avatar
                                                        radius: 30,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          child:
                                                              item.teacherPhoto ==
                                                                      null
                                                                  ? Image.asset(
                                                                      'assets/images/Teacher.jpg',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image
                                                                      .network(
                                                                      item.urlSource == "web" ||
                                                                              item.urlSource == "Web"
                                                                          ? '${webUrl}images/Profiles/${item.teacherPhoto}'
                                                                          : '${baseUrl0}Assets/ProfileImages/${item.teacherPhoto}',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      //------------------------------------Name & Rating
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.lessonName,
                                                          style: TextStyle(
                                                              color:
                                                                  defaultColor,
                                                              fontSize: 18),
                                                        ),
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          item.teacherName,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                      //----------------------------------------Statistics
                                                      width: 50,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .video_collection,
                                                                  color: Colors
                                                                      .black45),
                                                              SizedBox(
                                                                width: 3,
                                                              ),
                                                              Text(item.videos
                                                                  .toString())
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.quiz,
                                                                  color: Colors
                                                                      .black45),
                                                              SizedBox(
                                                                width: 3,
                                                              ),
                                                              Text(item.quizes
                                                                  .toString())
                                                            ],
                                                          ),
                                                        ],
                                                      ))
                                                ]),
                                            item.videosProgress > 0
                                                ? Container(
                                                    height: 10,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .video_collection_outlined,
                                                          size: 15,
                                                          color: Colors.green,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              Stack(children: [
                                                            FractionallySizedBox(
                                                              widthFactor:
                                                                  item.videosProgress >
                                                                          100
                                                                      ? 1
                                                                      : item.videosProgress /
                                                                          100,
                                                              heightFactor: 0.4,
                                                              child: Container(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                            Container(
                                                              height: 4,
                                                              color: Colors
                                                                  .black12,
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            // item.quizesProgress >
                                            //         0
                                            //     ? SizedBox(
                                            //         height: 4,
                                            //       )
                                            //     : Container(),
                                            // item.quizesProgress >
                                            //         0
                                            //     ? Container(
                                            //         height: 10,
                                            //         child: Row(
                                            //           crossAxisAlignment: CrossAxisAlignment.end,
                                            //           children: [
                                            //             Icon(
                                            //               Icons.quiz_outlined,
                                            //               size: 15,
                                            //               color: Colors.green,
                                            //             ),
                                            //             Expanded(
                                            //               child: Stack(children: [
                                            //                 FractionallySizedBox(
                                            //                   widthFactor: item.quizesProgress > 100 ? 1 : item.quizesProgress / 100,
                                            //                   heightFactor: 0.4,
                                            //                   child: Container(color: Colors.green),
                                            //                 ),
                                            //                 Container(
                                            //                   height: 4,
                                            //                   color: Colors.black12,
                                            //                 )
                                            //               ]),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       )
                                            //   : Container()
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black87
                                                  .withOpacity(0.3),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ));
  }
}

class EmptyWidget extends StatelessWidget {
  EmptyWidget(this.dir, {Key key}) : super(key: key);
  String dir;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Directionality(
      textDirection: dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/empty-folder.png",
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              dir == "ltr"
                  ? "You don't have any favorites!"
                  : 'لا يوجد لديك مفضلات!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
