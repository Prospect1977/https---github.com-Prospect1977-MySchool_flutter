import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_school/cubits/StudentSessionHeaderDetail_cubit.dart';
import 'package:my_school/cubits/StudentSessionHeaderDetail_states.dart';
import 'package:my_school/models/StudentSessionHeaderDetail.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/quiz_screen.dart';
import 'package:my_school/screens/studentLessonSessions_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class StudentSessionDetailsScreen extends StatefulWidget {
  final int SessionHeaderId;

  final String LessonName;
  final String LessonDescription;
  final String dir;
  final int StudentId;
  final String TeacherName;
  StudentSessionDetailsScreen(
      {@required this.SessionHeaderId,
      @required this.LessonName,
      @required this.LessonDescription,
      @required this.dir,
      @required this.StudentId,
      @required this.TeacherName,
      Key key})
      : super(key: key);

  @override
  bool isRated = false;
  double rate = 0;
  State<StudentSessionDetailsScreen> createState() =>
      _StudentSessionDetailsScreenState();
}

class _StudentSessionDetailsScreenState
    extends State<StudentSessionDetailsScreen> {
  AllData allData;
  @override
  void initState() {
    super.initState();

    getSessionDetails(widget.StudentId, widget.SessionHeaderId);
  }

  void getSessionDetails(StudentId, SessionHeaderId) {
    DioHelper.getData(
            url: 'StudentSessionHeaderDetails',
            query: {'Id': StudentId, 'SessionHeaderId': SessionHeaderId},
            lang: widget.dir == "ltr" ? "en" : "ar",
            token: CacheHelper.getData(key: 'token'))
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {
        navigateAndFinish(context, LoginScreen());
        return;
      }
      setState(() {
        allData = AllData.fromJson(value.data["data"]);
      });
    }).catchError((error) {
      showToast(
          text: widget.dir == "ltr" ? "Unkown error occured!" : "حدث خطأ ما!",
          state: ToastStates.ERROR);
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    String align = widget.dir == "ltr" ? "left" : "right";
    return Scaffold(
      appBar: appBarComponent(context, widget.TeacherName),
      body: RefreshIndicator(
          onRefresh: () async {
            await getSessionDetails(widget.StudentId, widget.SessionHeaderId);
          },
          child: allData == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 7),
                            decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: defaultColor.withOpacity(0.4),
                                    width: 1)),
                            child: Column(
                              children: [
                                Text(
                                  widget.LessonName,
                                  style: TextStyle(
                                      fontSize: 17, color: defaultColor),
                                ),
                                widget.LessonDescription != null
                                    ? Text(
                                        widget.LessonDescription,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.purple.shade300),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height - 250,
                            child: ListView.builder(
                              itemCount: allData.sessionDetails.length,
                              itemBuilder: (context, index) {
                                var item = allData.sessionDetails[index];
                                return Item(
                                    item: item,
                                    cubit: allData,
                                    widget: widget,
                                    align: align);
                              },
                            ),
                          ),
                          (allData.sessionHeader.isFree ||
                                  allData.sessionHeader.isPurchased)
                              ? Container(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: RatingBar.builder(
                                            initialRating: allData.sessionHeader
                                                        .studentRate ==
                                                    null
                                                ? 0.0
                                                : double.parse(allData
                                                    .sessionHeader.studentRate
                                                    .toStringAsFixed(2)),
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 30,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              setState(() {
                                                widget.isRated = true;
                                                widget.rate = rating;
                                              });
                                              // if (state is RatingSavedState) {
                                              //   widget.isRated = false;
                                              // }
                                            },
                                          ),
                                        ),
                                        widget.isRated
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  StudentSessionHeaderDetailCubit
                                                          .get(context)
                                                      .postRate(
                                                          widget.StudentId,
                                                          widget
                                                              .SessionHeaderId,
                                                          widget.rate);
                                                  setState(() {
                                                    widget.isRated = false;
                                                  });
                                                },
                                                child: Text("Ok"),
                                              )
                                            : Container()
                                      ]),
                                )
                              : defaultButton(
                                  function: () {
                                    StudentSessionHeaderDetailCubit.get(context)
                                        .postPurchase(
                                      widget.StudentId,
                                      widget.SessionHeaderId,
                                    );
                                    setState(() {
                                      allData.sessionHeader.isPurchased = true;
                                    });
                                  },
                                  text: widget.dir == "ltr"
                                      ? "Purchase (${allData.sessionHeader.price} EGP)"
                                      : "شراء ${allData.sessionHeader.price} ج.م"),
                        ]),
                  ))),
    );
  }
}

class Item extends StatelessWidget {
  Item({
    Key key,
    @required this.item,
    @required this.widget,
    @required this.align,
    @required this.cubit,
  }) : super(key: key);

  final SessionDetails item;

  final StudentSessionDetailsScreen widget;
  final String align;
  final AllData cubit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.type == "Video" || item.type == "Promo") {
          navigateTo(
              context,
              VideoScreen(
                StudentId: widget.StudentId,
                VideoId: item.videoId,
                VideoUrl: item.videoUrl,
                Title: item.title,
                SessionHeaderId: widget.SessionHeaderId,
                LessonName: widget.LessonName,
                LessonDescription: widget.LessonDescription,
                dir: widget.dir,
                TeacherName: widget.TeacherName,
                VideoName: item.title,
              ));
        }
        if (item.type == "Quiz") {
          navigateTo(context,
              QuizScreen(StudentId: widget.StudentId, QuizId: item.quizId));
        }
      },
      child: Card(
        //----------------------------------------------Card
        elevation: (cubit.sessionHeader.isFree ||
                cubit.sessionHeader.isPurchased ||
                item.type == "Promo")
            ? 3
            : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: (cubit.sessionHeader.isFree ||
                          cubit.sessionHeader.isPurchased ||
                          item.type == "Promo")
                      ? defaultColor.withOpacity(0.5)
                      : Colors.black26),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitle(
                          widget.dir,
                          widget.LessonName,
                          item,
                          cubit.sessionHeader.isFree,
                          cubit.sessionHeader.isPurchased,
                          16.1)
                    ],
                  ),
                ),
                getImage(
                  item,
                  cubit.sessionHeader.isFree,
                  cubit.sessionHeader.isPurchased,
                  align,
                  60.0,
                  60.0,
                ),
              ]),
              item.videoProgress > 0 || item.quizProgress > 0
                  ? Container(
                      height: 3,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            color: Colors.black12,
                          ),
                          FractionallySizedBox(
                            widthFactor: (item.type == "Video"
                                        ? item.videoProgress
                                        : item.quizProgress) >
                                    100
                                ? 100
                                : (item.type == "Video"
                                        ? item.videoProgress
                                        : item.quizProgress) /
                                    100,
                            heightFactor: 1,
                            child: Container(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

Widget getImage(SessionDetails sd, bool isFree, bool isPurchased, String align,
    double width, double height) {
  switch (sd.type) {
    case "Promo":
      return Image.asset(
        'assets/images/${sd.type}_$align.png',
        width: width,
        height: height,
      );
      break;
    default:
      if (isFree == true || isPurchased == true) {
        return Image.asset(
          'assets/images/${sd.type}_$align.png',
          width: width,
          height: height,
        );
      } else {
        return Image.asset(
          'assets/images/${sd.type}_${align}_disabled.png',
          width: width,
          height: height,
        );
      }
      break;
  }
}

Widget getTitle(String dir, String LessonName, SessionDetails sd, bool isFree,
    bool isPurchased, double fontSize) {
  switch (sd.type) {
    case "Promo":
      return Text(sd.title,
          style: TextStyle(fontSize: fontSize, color: defaultColor));
      break;
    case "Video":
      var title = sd.title;
      if (sd.title.trim() == LessonName.trim()) {
        title = dir == "ltr" ? "Video" : "فيديو";
      }
      if (isFree == true || isPurchased == true) {
        return Text(title,
            style: TextStyle(fontSize: fontSize, color: defaultColor));
      } else {
        return Text(title,
            style: TextStyle(fontSize: fontSize, color: Colors.black45));
      }
      break;
    default:
      if (isFree == true || isPurchased == true) {
        return Text(sd.title,
            style: TextStyle(fontSize: fontSize, color: defaultColor));
      } else {
        return Text(sd.title,
            style: TextStyle(fontSize: fontSize, color: Colors.black45));
      }
      break;
  }
}
