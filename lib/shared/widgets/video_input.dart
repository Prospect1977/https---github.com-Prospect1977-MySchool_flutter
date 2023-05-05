import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:my_school/shared/widgets/progress_dialog_widget.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

//----------------------------------------------------------------------
Future<String> compressVideo(XFile f, int VideoId, var ctx) async {
  //not used at the moment
  final file = File(f.path);
  var result = await ImageCropper().cropImage(
    sourcePath: f.path,
    aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 2),
    aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
    compressQuality: 70,
    compressFormat: ImageCompressFormat.jpg,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: defaultColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
      WebUiSettings(
        context: ctx,
      ),
    ],
  );
  return result.path;
}

//------------------------------------------------------------------------

generateThumbnail(
    int VideoId, var context, Function getData, File fileVideo) async {
  try {
    final thumbnail = await VideoCompress.getFileThumbnail(fileVideo.path);
    FormData formData = new FormData.fromMap({
      "image": await MultipartFile.fromFile(thumbnail.path,
          filename: thumbnail.path.split("/").last,
          contentType: new MediaType('file', '*/*')),
      "type": "file"
    });

    DioHelper.postImage(
            url: 'TeacherSession/TeacherUploadVideoThumbnail',
            data: formData,
            query: {
              "VideoId": VideoId,
            },
            lang: "en",
            token: "")
        .then((value) {
      print(value.data["data"]);
      Navigator.of(context).pop();
      getData();
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  } catch (e) {
    Navigator.of(context).pop();
    getData();
  }
}

class UploadProgressDialog extends StatefulWidget {
  UploadProgressDialog(
      {this.TeacherId, this.LessonId, this.IsPromo, this.getData, key})
      : super(key: key);

  int TeacherId;
  int LessonId;
  bool IsPromo;
  Function getData;
  @override
  State<UploadProgressDialog> createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  Future<void> UploadVideo(
      {var context,
      int TeacherId,
      int LessonId,
      bool IsPromo,
      Function getData}) async {
    XFile pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) {
      return;
    }
    final fileVideo = File(pickedFile.path);
    String filename = await pickedFile.path.split("/").last;

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Dialog(child: ProgressDialogWidget()),
    // );

    // var info = VideoCompress.compressVideo(fileVideo.path,
    //         deleteOrigin: false, quality: VideoQuality.MediumQuality)
    //     .then((value) async {

    FormData formData = new FormData.fromMap({
      "image": await MultipartFile.fromFile(fileVideo.path,
          filename: filename, contentType: new MediaType('file', '*/*')),
      "type": "file"
    });
    double Duration;
    int Height;
    int Width;
    await VideoCompress.getMediaInfo(fileVideo.path).then((info) {
      Duration = info.duration;
      Height = info.width;
      Width = info.height;
    });
    DioHelper.postVideo(
            url: 'TeacherSession/TeacherUploadVideo',
            data: formData,
            query: {
              "TeacherId": TeacherId,
              "LessonId": LessonId,
              "IsPromo": IsPromo,
              "Height": Height,
              "Width": Width,
              "Duration": Duration / 1000,
              "DataDate": DateTime.now()
            },
            lang: "en",
            updateProgress: updateProgress,
            token: "")
        .then((value) {
      print(value.data["data"]);

      generateThumbnail(value.data["data"], context, getData, fileVideo);
      //getData();
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  }

  var bytesUploaded;
  var bytesTotal = 0;
  void updateProgress(var uploaded, var from) {
    setState(() {
      bytesUploaded = uploaded;
      bytesTotal = from;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UploadVideo(
        IsPromo: widget.IsPromo,
        LessonId: widget.LessonId,
        TeacherId: widget.TeacherId,
        context: context,
        getData: widget.getData);
  }

  @override
  Widget build(BuildContext context) {
    return bytesTotal == 0
        ? SizedBox(
            height: 1,
            width: 1,
          )
        : Container(
            height: 100,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'Uploading Video',
                  style: TextStyle(color: defaultColor, fontSize: 18),
                ),
                SizedBox(
                  height: 8,
                ),
                LinearProgressIndicator(
                  value: bytesUploaded / bytesTotal,
                  minHeight: 12,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '${(bytesUploaded * 100 / bytesTotal).toStringAsFixed(0)} %',
                  style: TextStyle(color: Colors.black45),
                )
              ],
            ),
          );
  }
}
