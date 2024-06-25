import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  bool _isDownloaded = false;
  String _videoUrl =
      'https://prospect79-001-site3.ftempurl.com/Sessions/Videos/88dc1_Prep.2%20-%20Science%20-%20Unit%201%20-%20Lesson%201%20-%20Part%20(1_3)%20-%20Attempts%20of%20elements%20Classification_480.mp4';
  String _fileName =
      '88dc1_Prep.2%20-%20Science%20-%20Unit%201%20-%20Lesson%201%20-%20Part%20(1_3)%20-%20Attempts%20of%20elements%20Classification_480.mp4';

  String _filePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    Directory dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/$_fileName';

    if (await File(_filePath).exists()) {
      // Play video from storage if it exists
      _isDownloaded = true;
      _controller = VideoPlayerController.file(File(_filePath))
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
        });
    } else {
      // Play video from network if it doesn't exist in storage
      _controller = VideoPlayerController.network(_videoUrl)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
        });
    }
  }

  Future<void> _downloadVideo() async {
    Dio dio = Dio();
    try {
      await dio.download(_videoUrl, _filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + "%");
        }
      });

      setState(() {
        _isDownloaded = true;
        _controller = VideoPlayerController.file(File(_filePath))
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteVideo() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _isDownloaded = false;
          _controller = VideoPlayerController.network(_videoUrl)
            ..initialize().then((_) {
              setState(() {});
              _controller.play();
            });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player Example'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _controller.value.isInitialized
                ? Column(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      VideoProgressIndicator(_controller, allowScrubbing: true),
                      _isDownloaded
                          ? Container()
                          : ElevatedButton(
                              onPressed: _downloadVideo,
                              child: Text('Download Video'),
                            ),
                    ],
                  )
                : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller != null
              ? _controller.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow
              : Icons.access_time,
        ),
      ),
    );
  }
}
