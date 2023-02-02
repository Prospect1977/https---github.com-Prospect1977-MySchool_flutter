import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:video_player/video_player.dart';

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
  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.network(
    //     '${webUrl}Sessions/Videos/${widget.VideoUrl}')
    // _controller = VideoPlayerController.network(
    //     'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4')
    _controller = VideoPlayerController.asset('assets/images/Video.mp4')
      ..addListener(() {
        if (_controller != null && _controller.value.isInitialized) {
          //print('Play Time=${_controller.value.position.inSeconds}');

        }

        setState(() {});
      })
      ..setLooping(false)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })
      ..play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, widget.Title),
      body: Center(
        child: _controller != null && _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller != null) {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
