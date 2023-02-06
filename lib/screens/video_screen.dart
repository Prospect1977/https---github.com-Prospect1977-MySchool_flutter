import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
//import 'package:my_school/cubits/StudentVideo_cubit.dart';
//import 'package:my_school/providers/StudentVideo_provider.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoScreen extends StatefulWidget {
  int StudentId;
  int VideoId;
  String VideoUrl;
  String Title;
  VideoScreen(
      {@required this.StudentId,
      @required this.VideoId,
      @required this.VideoUrl,
      @required this.Title,
      Key key})
      : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  bool showControls;
  int stoppedAt;

  double IndicatorPosition = 0.0;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  int lastSavedAt;
  @override
  void initState() {
    super.initState();
    stoppedAt = 0;
    showControls = false;
    // _controller = VideoPlayerController.network(
    //     '${webUrl}Sessions/Videos/${widget.VideoUrl}')
    // _controller = VideoPlayerController.network(
    //     'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4')
    _controller = VideoPlayerController.asset('assets/images/Video.mp4')
      ..addListener(() {
        if (_controller != null && _controller.value.isInitialized) {
          setState(() {});
        }
      })
      ..setLooping(false)
      ..initialize().then((_) {
        DioHelper.getData(query: {
          "StudentId": widget.StudentId,
          "VideoId": widget.VideoId
        }, url: "StudentUpdateVideoProgress", lang: lang, token: token)
            .then((value) {
          print(
              'Stopped At============================================================================$value');
          _controller.seekTo(Duration(seconds: value.data));
        });

        setState(() {
          IndicatorPosition = MediaQuery.of(context).size.width *
              (_controller.value.position.inSeconds /
                  _controller.value.duration.inSeconds);
        });
      })
      ..play();
  }

  @override
  void dispose() {
    super.dispose();
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

  void anything() {
    if (_controller != null && _controller.value.isInitialized) {
      var currentSecond = _controller.value.position.inSeconds;
      if (currentSecond % 5 == 0 &&
          currentSecond > 0 &&
          currentSecond != lastSavedAt) {
        lastSavedAt = currentSecond;

        print(
            "Saved at -------------------------------------------${currentSecond}");
        DioHelper.postData(
            url: 'StudentUpdateVideoProgress',
            query: {
              "StudentId": widget.StudentId,
              "VideoId": widget.VideoId,
              "CurrentSecond": currentSecond,
              "VideoDuration": _controller.value.duration.inSeconds,
              "SaveInterval": 5,
              "DataDate": DateTime.now(),
            },
            lang: lang,
            token: token,
            data: {}).then((value) {}).catchError((error) {
          print(error.toString());
        });
        // ..saveProgress(context, widget.StudentId, widget.VideoId,
        //     _controller.value.position.inSeconds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    anything();
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      Wakelock.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      Wakelock.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? appBarComponent(context, widget.Title)
          : null,
      body: Column(children: [
        _controller != null && _controller.value.isInitialized
            ? Container(
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
                    });
                  },
                  child: Stack(alignment: Alignment.center, children: [
                    VideoPlayer(_controller),

                    //_controller.value.isPlaying
                    showControls == false
                        ? Container()
                        : Container(
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
                                                  _controller
                                                      .value.isInitialized) {
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
                                                    _controller
                                                        .value.isInitialized) {
                                                  if (_controller
                                                      .value.isPlaying) {
                                                    _controller.pause();
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
                                                  _controller
                                                      .value.isInitialized) {
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
                                              height: 12,
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
                                                    // Positioned(
                                                    //     //---------------------------------------Time Circle
                                                    //     top: 0,
                                                    //     bottom: 3,
                                                    //     left: IndicatorPosition,
                                                    //     child: Icon(
                                                    //       Icons.circle,
                                                    //       color: defaultColor,
                                                    //       size: 15,
                                                    //     )),
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
                                        height: 20,
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Row(
                                          //-------------------------------------------Add Note row
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 15),
                                              width: 20,
                                              height: 20,
                                              child: Icon(
                                                Icons.note_alt_outlined,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 20,
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
                                                          SystemUiMode.manual,
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
                          )
                  ]),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}
