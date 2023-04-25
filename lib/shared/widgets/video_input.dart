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
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(child: ProgressDialogWidget()),
  );

  var info = VideoCompress.compressVideo(fileVideo.path,
          deleteOrigin: false, quality: VideoQuality.MediumQuality)
      .then((value) async {
    // duration = value.duration;
    // height = value.height;
    FormData formData = new FormData.fromMap({
      "image": await MultipartFile.fromFile(value.path,
          filename: filename, contentType: new MediaType('file', '*/*')),
      "type": "file"
    });

    DioHelper.postImage(
            url: 'TeacherSession/TeacherUploadVideo',
            data: formData,
            query: {
              "TeacherId": TeacherId,
              "LessonId": LessonId,
              "IsPromo": IsPromo,
              "Height": value.height,
              "Duration": value.duration / 1000,
              "DataDate": DateTime.now()
            },
            lang: "en",
            token: "")
        .then((value) {
      print(value.data["data"]);
      Navigator.of(context).pop();
      generateThumbnail(value.data["data"], context, getData, fileVideo);
      //getData();
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  });
  // var croppedPath = await cropImage(pickedFile);
}

generateThumbnail(
    int VideoId, var context, Function getData, File fileVideo) async {
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

    getData();
  }).onError((error, stackTrace) {
    print(error.toString());
  });
}
