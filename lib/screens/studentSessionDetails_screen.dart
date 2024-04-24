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
import 'package:my_school/screens/document_screen.dart';

import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/paymob_options_screen.dart';
import 'package:my_school/screens/paymob_creditcard_screen.dart';
import 'package:my_school/screens/quiz_screen.dart';
import 'package:my_school/screens/require_update_screen.dart';
import 'package:my_school/screens/studentLessonSessions_screen.dart';
import 'package:my_school/screens/video_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/components/functions.dart';

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
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  String roles = CacheHelper.getData(key: "roles");
  void _checkAppVersion() async {
    await checkAppVersion();
    bool isUpdated = CacheHelper.getData(key: "isLatestVersion");
    if (isUpdated == false) {
      navigateTo(context, RequireUpdateScreen());
    }
  }

  @override
  void initState() {
    super.initState();

    getSessionDetails(widget.StudentId, widget.SessionHeaderId);
  }

  void getSessionDetails(StudentId, SessionHeaderId) {
    print("---------------------------------StudentId:${StudentId}");
    print(
        "---------------------------------SessionHeaderId:${SessionHeaderId}");

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

  void postRate(StudentId, SessionHeaderId, Rate) {
    DioHelper.postData(
            url: 'StudentSessionRate',
            data: {},
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              "Rate": Rate
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {}
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }

  void postPurchase(StudentId, SessionHeaderId) {
    DioHelper.postData(
            url: 'StudentPurchaseSession',
            data: {},
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              'DataDate': DateTime.now(),
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {}
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }

  void UpdateLessonProgress(StudentId, SessionHeaderId) {
    DioHelper.postData(
            url: 'StudentSessionHeaderDetails',
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              "DataDate": DateTime.now()
            },
            lang: lang,
            data: {},
            token: token)
        .then((value) {
      print(value.data["data"]);
    }).catchError((error) {
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: allData.sessionDetails.length,
                              itemBuilder: (context, index) {
                                var item = allData.sessionDetails[index];
                                return Item(
                                  item: item,
                                  cubit: allData,
                                  widget: widget,
                                  align: align,
                                  roles: roles,
                                );
                              },
                            ),
                          ),
                          (allData.sessionHeader.isFree ||
                                  allData.sessionHeader.isPurchaseCompleted)
                              ? Container(
                                  height: 80,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: RatingBar.builder(
                                              initialRating: allData
                                                          .sessionHeader
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
                                        ),
                                        widget.isRated
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  postRate(
                                                      widget.StudentId,
                                                      widget.SessionHeaderId,
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
                              : allData.sessionHeader.isPurchaseExist &&
                                      allData.sessionHeader.source == "kiosk"
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: Column(children: [
                                        Container(
                                          width: double.infinity,
                                          height: 55,
                                          margin: EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Center(
                                            child: Text(
                                              widget.dir == "ltr"
                                                  ? "Payment Code: ${allData.sessionHeader.kioskNumber}"
                                                  : ' كود الدفع: ${allData.sessionHeader.kioskNumber}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          widget.dir == "ltr" ? "OR" : "أو",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        defaultButton(
                                            borderRadius: 8,
                                            function: () {
                                              // postPurchase(
                                              //   widget.StudentId,
                                              //   widget.SessionHeaderId,
                                              // );
                                              setState(() {
                                                Navigator.of(context).pop();
                                                navigateTo(
                                                    context,
                                                    PaymobCreditCardScreen(
                                                        StudentId:
                                                            widget.StudentId,
                                                        SessionHeaderId: widget
                                                            .SessionHeaderId,
                                                        Payment: allData
                                                            .sessionHeader
                                                            .price,
                                                        LessonName:
                                                            widget.LessonName,
                                                        LessonDescription: widget
                                                            .LessonDescription,
                                                        dir: widget.dir,
                                                        TeacherName: widget
                                                            .TeacherName));
                                                //allData.sessionHeader.isPurchased = true;
                                              });
                                            },
                                            text: widget.dir == "ltr"
                                                ? "Purchase with Bank Card (${allData.sessionHeader.price} EGP)"
                                                : "شراء ببطاقة البنك ${allData.sessionHeader.price} ج.م"),
                                      ]),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: defaultButton(
                                          function: () {
                                            // postPurchase(
                                            //   widget.StudentId,
                                            //   widget.SessionHeaderId,
                                            // );
                                            setState(() {
                                              Navigator.of(context).pop();
                                              navigateTo(
                                                  context,
                                                  PaymobOptionsScreen(
                                                    StudentId: widget.StudentId,
                                                    Payment: allData
                                                            .sessionHeader
                                                            .price *
                                                        100,
                                                    SessionHeaderId:
                                                        widget.SessionHeaderId,
                                                    LessonDescription: widget
                                                        .LessonDescription,
                                                    LessonName:
                                                        widget.LessonName,
                                                    TeacherName:
                                                        widget.TeacherName,
                                                    dir: widget.dir,
                                                  ));
                                              //allData.sessionHeader.isPurchased = true;
                                            });
                                          },
                                          text: widget.dir == "ltr"
                                              ? "Purchase (${allData.sessionHeader.price} EGP)"
                                              : "شراء ${allData.sessionHeader.price} ج.م"),
                                    ),
                        ]),
                  ))),
    );
  }
}

//
class Item extends StatelessWidget {
  Item(
      {Key key,
      @required this.item,
      @required this.widget,
      @required this.align,
      @required this.cubit,
      @required this.roles})
      : super(key: key);

  final SessionDetails item;

  final StudentSessionDetailsScreen widget;
  final String align;
  final AllData cubit;
  final roles;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (cubit.sessionHeader.isFree ||
              cubit.sessionHeader.isPurchaseCompleted ||
              item.type == "Promo")
          ? () async {
              if (item.type == "Video" || item.type == "Promo") {
                navigateTo(
                    context,
                    VideoScreen(
                      StudentId: widget.StudentId,
                      VideoId: item.videoId,
                      VideoUrl: item.videoUrl,
                      CoverUrl: item.coverUrlSource == "web" ||
                              item.coverUrlSource == "Web"
                          ? "${webUrl}Sessions/VideoCovers/${item.videoCover}"
                          : "${baseUrl0}Sessions/VideoCovers/${item.videoCover}",
                      aspectRatio: item.aspectRatio,
                      UrlSource: item.urlSource,
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
                bool readOnly;
                bool allowRetry;
                if (roles == "Student") {
                  if (item.quizProgress > 0) {
                    readOnly = true;
                    allowRetry = true;
                  } else {
                    readOnly = false;
                    allowRetry = false;
                  }
                } else {
                  readOnly = true;
                  allowRetry = false;
                }
                navigateTo(
                    context,
                    QuizScreen(
                      StudentId: widget.StudentId,
                      QuizId: item.quizId,
                      LessonName: widget.LessonName,
                      dir: widget.dir,
                    ));
              }
              if (item.type == "Document") {
                // navigateTo(
                //     context,
                //     DocumentScreen(
                //         Url: item.urlSource == "web"
                //             ? '${webUrl}Sessions/Documents/${item.documentUrl}'
                //             : '${baseUrl0}Sessions/Documents/${item.documentUrl}',
                //         Title: item.title));

                await launchUrl(
                    Uri.parse(item.urlSource == "web" || item.urlSource == "Web"
                        ? '${webUrl}Sessions/Documents/${item.documentUrl}'
                        : '${baseUrl0}Sessions/Documents/${item.documentUrl}'),
                    mode: LaunchMode.externalApplication);
              }
            }
          : null,
      child: Card(
        //----------------------------------------------Card
        elevation: (cubit.sessionHeader.isFree ||
                cubit.sessionHeader.isPurchaseCompleted ||
                item.type == "Promo")
            ? 1
            : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: (cubit.sessionHeader.isFree ||
                          cubit.sessionHeader.isPurchaseCompleted ||
                          item.type == "Promo")
                      ? defaultColor.withOpacity(0.5)
                      : Colors.black26),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Row(children: [
                item.type == "Video" || item.type == "Promo"
                    ? Stack(
                        children: [
                          getImage(
                            item,
                            cubit.sessionHeader.isFree,
                            cubit.sessionHeader.isPurchaseCompleted,
                            align,
                            60.0,
                            60.0,
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.black26,
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/play.png",
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      getVideoDuration(item.duration),
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ]),
                            ),
                          ),
                        ],
                      )
                    : getImage(
                        item,
                        cubit.sessionHeader.isFree,
                        cubit.sessionHeader.isPurchaseCompleted,
                        align,
                        60.0,
                        60.0,
                      ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitle(
                          widget.dir,
                          widget.LessonName,
                          item,
                          cubit.sessionHeader.isFree,
                          cubit.sessionHeader.isPurchaseCompleted,
                          16.1)
                    ],
                  ),
                ),
              ]),
              SizedBox(
                height: 3,
              ),
              item.videoProgress > 0 || item.quizProgress > 0
                  ? Container(
                      height: 4.5,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            color: Colors.black12,
                          ),
                          FractionallySizedBox(
                            widthFactor: (item.type == "Video"
                                        ? (roles == "Student"
                                            ? item.videoStoppedAt > 100
                                                ? 100
                                                : item.videoStoppedAt
                                            : item.videoProgress > 100
                                                ? 100
                                                : item.videoProgress)
                                        : item.quizDegree) >
                                    100
                                ? 100
                                : (item.type == "Video"
                                        ? (roles == "Student"
                                            ? item.videoStoppedAt
                                            : item.videoProgress > 100
                                                ? 100
                                                : item.videoProgress)
                                        : item.quizDegree) /
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
  if (align == "left") {
    align = "right";
  } else {
    align = "left";
  }
  switch (sd.type) {
    case "Promo":
      return Image.network(
        //'assets/images/${sd.type}_left.png',
        '${sd.coverUrlSource == "web" || sd.coverUrlSource == "Web" ? webUrl : baseUrl0}Sessions/VideoCovers/${sd.videoCover}',
        width: 60,
        height: 60, fit: BoxFit.cover,
      );
      break;
    case "Video":
      return Image.network(
        '${sd.coverUrlSource == "web" || sd.coverUrlSource == "Web" ? webUrl : baseUrl0}Sessions/VideoCovers/${sd.videoCover}',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
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

String getVideoDuration(dur) {
  final duration = Duration(milliseconds: dur * 1000);

  return [duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}
