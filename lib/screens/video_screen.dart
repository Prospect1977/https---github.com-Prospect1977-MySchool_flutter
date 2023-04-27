import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/StudentVideoNote_model.dart';
import 'package:my_school/providers/StudentVideo_provider.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentSessionDetails_screen.dart';
//import 'package:my_school/cubits/StudentVideo_cubit.dart';
//import 'package:my_school/providers/StudentVideo_provider.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/teacher_session_navigation_bar.dart';
import 'package:video_compress/video_compress.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoScreen extends StatefulWidget {
  int StudentId;
  int VideoId;
  String VideoUrl;
  String Title;
  int SessionHeaderId;
  String LessonName;
  String LessonDescription;
  String dir;
  String TeacherName;
  String VideoName;
  int GoToSecond;
  VideoScreen(
      {@required this.StudentId,
      @required this.VideoId,
      @required this.VideoUrl,
      @required this.Title,
      this.SessionHeaderId,
      @required this.LessonName,
      @required this.LessonDescription,
      @required this.dir,
      @required this.TeacherName,
      @required this.VideoName,
      this.GoToSecond,
      Key key})
      : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  bool showControls;
  int stoppedAt;
  String roles = CacheHelper.getData(key: "roles");
  double IndicatorPosition = 0.0;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  int lastSavedAt;
  String commentMode = "create"; //create or update
  int editCommentId = 0;
  int secondsCounter = 0;
  double playbackSpeed = 1.0;
  int currentRes = 480;
  bool showSpeedOptions = false;
  bool showResOptions = false;
  String VideoUrl;
  @override
  StudentVideoNotes VideoNotes;
  Future<void> _initializePlay(String VideoUrl) async {
    _controller = VideoPlayerController.asset(VideoUrl)
      ..addListener(() {
        if (_controller != null && _controller.value.isInitialized) {
          setState(() {});
        }
      })
      ..setLooping(false)
      ..setPlaybackSpeed(playbackSpeed)
      ..initialize().then((_) {
        if (roles != 'Teacher') {
          if (widget.GoToSecond != null) {
            _controller.seekTo(Duration(seconds: widget.GoToSecond));
            return;
          }
          DioHelper.getData(query: {
            "StudentId": widget.StudentId,
            "VideoId": widget.VideoId
          }, url: "StudentUpdateVideoProgress", lang: lang, token: token)
              .then((value) {
            // print(
            //     'Stopped At============================================================================$value');
            _controller.seekTo(Duration(seconds: value.data));
          });
        }

        setState(() {
          IndicatorPosition = MediaQuery.of(context).size.width *
              (_controller.value.position.inSeconds /
                  _controller.value.duration.inSeconds);
          print('Indicator Position: ${_controller.value.position.inSeconds}');
        });
      })
      ..play();
  }

  void initState() {
    super.initState();

    if (CacheHelper.getData(key: "resolution") != null) {
      currentRes = CacheHelper.getData(key: "resolution");
    }
    GetVideoNotes();
    stoppedAt = 0;
    showControls = false;
    // _controller = VideoPlayerController.network(
    //     '${webUrl}Sessions/Videos/${widget.VideoUrl}')
    // _controller = VideoPlayerController.network(
    //     'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4')
    VideoUrl = widget.dir == "ltr"
        ? 'assets/images/Video.mp4'
        : 'assets/images/Video_ar.mp4';
    VideoUrl =
        '${VideoUrl.substring(0, VideoUrl.length - 4)}_${currentRes}.${VideoUrl.split(".")[VideoUrl.split(".").length - 1]}';
    // print(
    //     '________________________________________________________________vidUrl=$VideoUrl2');
    _initializePlay(VideoUrl);
  }

  void _setSpeed(double speed) {
    setState(() {
      playbackSpeed = speed;
      _controller.setPlaybackSpeed(speed);

      showControls = false;
      showSpeedOptions = false;
      showResOptions = false;
      _controller.play();
    });
  }

  void _setRes(int res) {
    setState(() {
      currentRes = res;
      showControls = false;
      showSpeedOptions = false;
      showResOptions = false;
      VideoUrl =
          '${VideoUrl.substring(0, VideoUrl.length - 4)}_${res}.${VideoUrl.split(".")[VideoUrl.split(".").length - 1]}';
      //_controller = VideoPlayerController.asset(VideoUrl)
      CacheHelper.saveData(key: "resolution", value: res);
      // saveProgress(context, widget.StudentId, widget.VideoId, secondsCounter);
      // navigateTo(
      //     context,
      //     VideoScreen(
      //         StudentId: widget.StudentId,
      //         VideoId: widget.VideoId,
      //         VideoUrl: VideoUrl,
      //         Title: widget.Title,
      //         LessonName: widget.LessonName,
      //         LessonDescription: widget.LessonDescription,
      //         dir: widget.dir,
      //         TeacherName: widget.TeacherName,
      //         VideoName: widget.VideoName));
    });
  }

  double getIndicatorPosition() {
    var pos = (MediaQuery.of(context).size.width -
                86) * //86=currentTimeLabelWidth + durationLabelWidth
            (_controller.value.position.inSeconds /
                _controller.value.duration.inSeconds) -
        5;
    return pos;
  }

  void GetVideoNotes() {
    DioHelper.getData(
      url: 'StudentVideoNote',
      query: {
        "StudentId": widget.StudentId,
        "VideoId": widget.VideoId,
      },
      lang: lang,
      token: token,
    ).then((value) {
      print(value.data);
      setState(() {
        VideoNotes = StudentVideoNotes.fromJson(value.data["data"]);
      });
    }).catchError((error) {
      // print(error.toString());
    });
  }

  void DeleteVideoNote(int NoteId) {
    DioHelper.deleteData(
      url: 'StudentVideoNote',
      query: {
        "StudentId": widget.StudentId,
        "NoteId": NoteId,
      },
      lang: lang,
      token: token,
    ).then((value) {
      print(value.data);

      GetVideoNotes();
    }).catchError((error) {
      // print(error.toString());
    });
  }

  @override
  void dispose() {
    print(
        "--------------------------------Disposed at ${_controller.value.position.inSeconds}--------------------------------------------------");
    super.dispose();
    if (roles != 'Teacher') {
      SaveProgress(secondsCounter);
    }
    _controller.dispose();
  }

  String getPosition() {
    final duration = Duration(
        milliseconds: _controller.value.position.inMilliseconds.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String getVideoDuration() {
    final duration = Duration(
        milliseconds: _controller.value.duration.inMilliseconds.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String ConvertSecondsToTime(int Seconds) {
    final duration = Duration(milliseconds: Seconds * 1000);

    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  void SaveProgress(int interval /*i.e. save every 5 seconds*/) {
    // print(
    //     "Saved at -------------------------------------------${currentSecond}");
    if (roles != 'Teacher') {
      DioHelper.postData(
          url: 'StudentUpdateVideoProgress',
          query: {
            "StudentId": widget.StudentId,
            "VideoId": widget.VideoId,
            "CurrentSecond": _controller.value.position.inSeconds,
            "VideoDuration": _controller.value.duration.inSeconds,
            "SaveInterval": secondsCounter,
            "DataDate": DateTime.now(),
          },
          lang: lang,
          token: token,
          data: {}).then((value) {
        setState(() {
          secondsCounter = 0;
        });
      }).catchError((error) {
        // print(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller.value.isInitialized) {
      var currentSecond = _controller.value.position.inSeconds;
      if (currentSecond != lastSavedAt) {
        secondsCounter += 1;
        lastSavedAt = currentSecond;
      }
      // if ((currentSecond % 5 == 0 &&
      //         currentSecond > 0 &&
      //         currentSecond != lastSavedAt) ||
      //     currentSecond == _controller.value.duration) {
      //   lastSavedAt = currentSecond;
      //   SaveProgress(5);
      // }
    }
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      Wakelock.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      Wakelock.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
    var commentController = TextEditingController();
    void _saveNote() async {
      if (commentController.text == "") {
        return;
      }
      if (commentMode == "create") {
        DioHelper.postData(
            url: "StudentVideoNote",
            lang: lang,
            token: token,
            data: {},
            query: {
              "StudentId": widget.StudentId,
              "VideoId": widget.VideoId,
              "DataDate": DateTime.now(),
              "NoteTime": _controller.value.position.inSeconds,
              "Note": commentController.text,
            }).then((value) {
          if (value.data["status"] == false) {
            showToast(
                text: widget.dir == "ltr"
                    ? "Unkown error has occured!"
                    : "حدث خطأ ما!",
                state: ToastStates.ERROR);
            navigateAndFinish(context, LoginScreen());
          } else {
            Navigator.of(context).pop();
            showToast(text: value.data["message"], state: ToastStates.SUCCESS);
            GetVideoNotes();
          }
        });
      } else if (commentMode == "update") {
        DioHelper.updateData(
            url: "StudentVideoNote",
            lang: lang,
            token: token,
            data: {},
            query: {
              "StudentNoteId": editCommentId,
              "Note": commentController.text
            }).then((value) {
          if (value.data["status"] == false) {
            showToast(
                text: widget.dir == "ltr"
                    ? "Unkown error has occured!"
                    : "حدث خطأ ما!",
                state: ToastStates.ERROR);
            navigateAndFinish(context, LoginScreen());
          } else {
            Navigator.of(context).pop();
            showToast(text: value.data["message"], state: ToastStates.SUCCESS);
            GetVideoNotes();
          }
        });
      }
    }

    void _startAddComment({String ExistingComment}) {
      _controller.pause();
      if (ExistingComment != null) {
        commentController.text = ExistingComment;
      }
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return SingleChildScrollView(
              child: AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Directionality(
                    textDirection: widget.dir == "ltr"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            maxLines: 4,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius:
                                      BorderRadius.all(new Radius.circular(5)),
                                ),
                                hintText: widget.dir == "ltr"
                                    ? "Add your comment"
                                    : ""),
                            controller: commentController,
                            onSubmitted: (_) => _saveNote(),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _saveNote,
                                child:
                                    Text(widget.dir == "ltr" ? "Save" : "حفظ"),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                      widget.dir == "ltr" ? "Cancel" : "إلغاء",
                                      style: TextStyle(color: Colors.black54)))
                            ],
                          )
                        ]),
                  ),
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? appBarComponent(
              context,
              widget.Title,
              /*backButtonPage: StudentSessionDetailsScreen(
                  SessionHeaderId: widget.SessionHeaderId,
                  LessonName: widget.LessonName,
                  LessonDescription: widget.LessonDescription,
                  dir: widget.dir,
                  StudentId: widget.StudentId,
                  TeacherName: widget.TeacherName)*/
            )
          : null,
      body: _controller != null && _controller.value.isInitialized
          ? Column(children: [
              Container(
                width: MediaQuery.of(context).size.width -
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0
                        : 0), //----------------------------the 48 is to be removed latter
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width /
                            _controller.value.aspectRatio
                        : MediaQuery.of(context).size.height - 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      showControls = !showControls;
                      showSpeedOptions = false;
                      showResOptions = false;
                    });
                  },
                  child: Stack(alignment: Alignment.center, children: [
                    VideoPlayer(_controller),

                    //_controller.value.isPlaying
                    showControls == false
                        ? Container()
                        : Stack(
                            children: [
                              Container(
                                ////////---------------------------------------------controlles board
                                color: Colors.black26,
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              //--------------------------backward Button
                                              onPressed: () {
                                                setState(() {
                                                  if (_controller != null &&
                                                      _controller.value
                                                          .isInitialized) {
                                                    _controller.seekTo(Duration(
                                                        seconds: (_controller
                                                                .value
                                                                .position
                                                                .inSeconds -
                                                            15)));
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                Icons.fast_rewind,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                            Container(
                                              height: 60,
                                              width: 60,
                                              child: IconButton(
                                                //--------------------------Play Button
                                                onPressed: () {
                                                  setState(() {
                                                    if (_controller != null &&
                                                        _controller.value
                                                            .isInitialized) {
                                                      if (_controller
                                                          .value.isPlaying) {
                                                        _controller.pause();

                                                        SaveProgress(
                                                            secondsCounter);
                                                      } else {
                                                        _controller.play();
                                                        showControls = false;
                                                      }

                                                      // _controller.seekTo(Duration(seconds: 500));
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  _controller.value.isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              //--------------------------forward Button
                                              onPressed: () {
                                                setState(() {
                                                  if (_controller != null &&
                                                      _controller.value
                                                          .isInitialized) {
                                                    _controller.seekTo(Duration(
                                                        seconds: (_controller
                                                                .value
                                                                .position
                                                                .inSeconds +
                                                            15)));
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                Icons.fast_forward,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 55,
                                      child: Column(
                                        //-----------------------------------Bottom Compound Column
                                        children: [
                                          Row(
                                            //-------------------------------------------------Timeline row
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: 4, left: 3),
                                                width: 43,
                                                child: FittedBox(
                                                  child: Text(
                                                    getPosition(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 16,
                                                  child: Stack(
                                                      //----------------------------------video progress indicator Group
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      children: [
                                                        VideoProgressIndicator(
                                                          //----------------------------------video progress indicator
                                                          _controller,
                                                          allowScrubbing: true,
                                                          colors:
                                                              VideoProgressColors(
                                                            playedColor:
                                                                defaultColor,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left:
                                                              getIndicatorPosition(),
                                                          top: 2,
                                                          child: IgnorePointer(
                                                            child: Icon(
                                                              Icons.circle,
                                                              color:
                                                                  defaultColor,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: 3, left: 4),
                                                width: 43,
                                                child: FittedBox(
                                                  child: Text(
                                                    getVideoDuration(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 31,
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: Row(
                                              //-------------------------------------------Add Note row
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.landscape
                                                      ? () async {
                                                          SystemChrome
                                                              .setPreferredOrientations([
                                                            DeviceOrientation
                                                                .portraitUp,
                                                            DeviceOrientation
                                                                .portraitDown,
                                                          ]);
                                                          await Wakelock
                                                              .disable();
                                                          if (roles !=
                                                              "Teacher") {
                                                            commentMode =
                                                                "create";
                                                            editCommentId = 0;

                                                            _startAddComment(
                                                                ExistingComment:
                                                                    "");
                                                          } else {
                                                            showToast(
                                                                text: lang ==
                                                                        "en"
                                                                    ? "Only students and parents can add a notes!"
                                                                    : "فقط الطلاب وأولاياء الأمور بأمكانهم إضافة ملحوظات!",
                                                                state:
                                                                    ToastStates
                                                                        .ERROR);
                                                          }
                                                        }
                                                      : () {
                                                          if (roles !=
                                                              "Teacher") {
                                                            commentMode =
                                                                "create";
                                                            editCommentId = 0;

                                                            _startAddComment(
                                                                ExistingComment:
                                                                    "");
                                                          } else {
                                                            showToast(
                                                                text: lang ==
                                                                        "en"
                                                                    ? "Only students and parents can add a notes!"
                                                                    : "فقط الطلاب وأولاياء الأمور بأمكانهم إضافة ملحوظات!",
                                                                state:
                                                                    ToastStates
                                                                        .ERROR);
                                                          }
                                                        },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 15),
                                                    width: 30,
                                                    height: 30,
                                                    child: Icon(
                                                      Icons.note_alt_outlined,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  //--------------------------------------------Playback Speed
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                showSpeedOptions =
                                                                    true;
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.speed,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  '${playbackSpeed.toStringAsFixed(2)} X',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            )),
                                                        //-------------------------------------------------Resolution
                                                        //Reference to handle the problem: https://stackoverflow.com/questions/59010614/flutter-video-player-change-video-source-dynamically
                                                        GestureDetector(
                                                          child: Text(
                                                            '${currentRes.toString()} PX',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              showResOptions =
                                                                  true;
                                                            });
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    height: 30,
                                                    padding: EdgeInsets.all(0),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  //----------------------------------- Full screen button
                                                  child: Icon(
                                                    MediaQuery.of(context)
                                                                .orientation ==
                                                            Orientation.portrait
                                                        ? Icons.fullscreen
                                                        : Icons.fullscreen_exit,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                  onTap: () async {
                                                    if (MediaQuery.of(context)
                                                            .orientation ==
                                                        Orientation.portrait) {
                                                      SystemChrome
                                                          .setPreferredOrientations([
                                                        DeviceOrientation
                                                            .landscapeRight,
                                                        DeviceOrientation
                                                            .landscapeLeft,
                                                      ]);
                                                      await Wakelock.enable();
                                                      SystemChrome
                                                          .setEnabledSystemUIMode(
                                                              SystemUiMode
                                                                  .leanBack);
                                                    } else {
                                                      await Wakelock.disable();
                                                      SystemChrome
                                                          .setEnabledSystemUIMode(
                                                              SystemUiMode
                                                                  .manual,
                                                              overlays:
                                                                  SystemUiOverlay
                                                                      .values);
                                                      SystemChrome
                                                          .setPreferredOrientations([
                                                        DeviceOrientation
                                                            .portraitDown,
                                                        DeviceOrientation
                                                            .portraitUp,
                                                      ]);
                                                      SystemChrome
                                                          .setPreferredOrientations([
                                                        DeviceOrientation
                                                            .portraitDown,
                                                        DeviceOrientation
                                                            .portraitUp,
                                                        DeviceOrientation
                                                            .landscapeRight,
                                                        DeviceOrientation
                                                            .landscapeLeft,
                                                      ]);
                                                    }
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ////////-----------------------------------speed and res overlay
                              showResOptions
                                  ? ResController(
                                      setRes: _setRes, currentRes: currentRes)
                                  : Container(),
                              showSpeedOptions == true
                                  ? SpeedsController(
                                      setSpeed: _setSpeed,
                                      currentSpeed: playbackSpeed,
                                    )
                                  : Container(),
                            ],
                          )
                  ]),
                ),
              ),
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? Directionality(
                      textDirection: widget.dir == "ltr"
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      child: Container(
                        //---------------------------------------------------video title and ask
                        padding: EdgeInsets.all(5),
                        alignment: widget.dir == "ltr"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.VideoName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black45),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                          Colors.black.withOpacity(0.25),
                                      foregroundColor: Theme.of(context)
                                          .primaryTextTheme
                                          .button
                                          .color,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          side: BorderSide(
                                              color: Colors.black12))),
                                  child: Text(
                                    widget.dir == "ltr"
                                        ? "Ask a question"
                                        : "إسأل المُعلم",
                                    style: TextStyle(fontSize: 16),
                                  )),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
              VideoNotes != null &&
                      MediaQuery.of(context).orientation == Orientation.portrait
                  ? Divider()
                  : Container(),
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? Directionality(
                      textDirection: widget.dir == "ltr"
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      child: Expanded(
                          child: VideoNotes != null && roles != "Teacher"
                              ? ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      Divider(thickness: 1),
                                  itemCount: VideoNotes.items.length,
                                  itemBuilder: (context, index) {
                                    var item = VideoNotes.items[index];
                                    return Directionality(
                                      textDirection: widget.dir == "ltr"
                                          ? TextDirection.ltr
                                          : TextDirection.rtl,
                                      child: InkWell(
                                        onTap: () {
                                          _controller.seekTo(
                                              Duration(seconds: item.time));
                                        },
                                        child: Padding(
                                          //--------------------------------Note
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                //--------------------------Note left column
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 45,
                                                    height: 25,
                                                    margin: EdgeInsets.only(
                                                        bottom: 3),
                                                    decoration: BoxDecoration(
                                                        color: defaultColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40)),
                                                    child: Center(
                                                      //---------------------------Video Note time
                                                      child: Text(
                                                          ConvertSecondsToTime(
                                                              item.time),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 7,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .sticky_note_2_outlined,
                                                        color: Colors.black26,
                                                        size: 21,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        item.note,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black54),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )),
                                              PopupMenuButton(
                                                  icon: Icon(Icons.more_horiz,
                                                      color: Colors
                                                          .black54), // add this line
                                                  itemBuilder: (_) =>
                                                      <PopupMenuItem<String>>[
                                                        new PopupMenuItem<
                                                                String>(
                                                            child: Container(
                                                                width: 100,
                                                                // height: 30,
                                                                child: Text(
                                                                  widget.dir ==
                                                                          "ltr"
                                                                      ? "Edit"
                                                                      : "تعديل",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54),
                                                                )),
                                                            value: 'edit'),
                                                        new PopupMenuItem<
                                                                String>(
                                                            child: Container(
                                                                width: 100,
                                                                // height: 30,
                                                                child: Text(
                                                                  widget.dir ==
                                                                          "ltr"
                                                                      ? "Delete"
                                                                      : "حذف",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54),
                                                                )),
                                                            value: 'delete'),
                                                      ],
                                                  onSelected: (index) async {
                                                    switch (index) {
                                                      case 'delete': //--------------------------------------remove note
                                                        showDialog(
                                                            context: context,
                                                            builder: (ctx) =>
                                                                Directionality(
                                                                  textDirection: widget
                                                                              .dir ==
                                                                          "ltr"
                                                                      ? TextDirection
                                                                          .ltr
                                                                      : TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      AlertDialog(
                                                                    titleTextStyle: TextStyle(
                                                                        color:
                                                                            defaultColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    title: Text(widget.dir ==
                                                                            "ltr"
                                                                        ? 'Are you sure?'
                                                                        : "هل انت متأكد؟"),
                                                                    content:
                                                                        Text(
                                                                      widget.dir ==
                                                                              "ltr"
                                                                          ? 'Do you want to remove this note?'
                                                                          : "هل تريد حذف هذا السجل؟",
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        child: Text(widget.dir ==
                                                                                "ltr"
                                                                            ? "No"
                                                                            : "لا"),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: Text(widget.dir ==
                                                                                "ltr"
                                                                            ? 'Yes'
                                                                            : "نعم"),
                                                                        onPressed:
                                                                            () {
                                                                          DeleteVideoNote(
                                                                              item.id);
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ));

                                                        break;
                                                      case 'edit':
                                                        _startAddComment(
                                                            ExistingComment:
                                                                item.note);
                                                        setState(() {
                                                          commentMode =
                                                              "update";
                                                          editCommentId =
                                                              item.id;
                                                        });
                                                      //-------------------------------------Edit Note
                                                    }
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : roles != 'Teacher'
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container()),
                    )
                  : Container()
            ])
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class SpeedsController extends StatelessWidget {
  SpeedsController(
      {@required this.setSpeed, @required this.currentSpeed, Key key})
      : super(key: key);
  final Function setSpeed;
  final double currentSpeed;
  var speeds = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 2];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 14),
      color: Colors.black.withOpacity(0.75),
      child: Column(children: [
        ...speeds
            .map((e) => GestureDetector(
                  onTap: () {
                    setSpeed(e);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${e.toStringAsFixed(2)} X',
                        style: TextStyle(
                            color: e == currentSpeed
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            fontWeight: e == currentSpeed
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.4),
                        thickness: 1,
                      )
                    ],
                  ),
                ))
            .toList()
      ]),
    );
  }
}

class ResController extends StatelessWidget {
  ResController({@required this.setRes, @required this.currentRes, Key key})
      : super(key: key);
  Function setRes;
  int currentRes;
  var resolutions = <int>[144, 240, 360, 480];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 14),
      color: Colors.black.withOpacity(0.75),
      child: Column(children: [
        ...resolutions
            .map((e) => GestureDetector(
                  onTap: () {
                    setRes(e);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${e.toString()} px',
                        style: TextStyle(
                            color: e == currentRes
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            fontWeight: e == currentRes
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.4),
                        thickness: 1,
                      )
                    ],
                  ),
                ))
            .toList()
      ]),
    );
  }
}
