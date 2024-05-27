import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:my_school/shared/dio_helper.dart';

import '../cache_helper.dart';

Future<void> UploadFile(
    {var context, int TeacherId, int LessonId, Function getData}) async {
  var pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false, type: FileType.custom, allowedExtensions: ['pdf']);

  if (pickedFile == null) {
    return;
  }
  final file = File(pickedFile.files[0].path);
  String filename = await pickedFile.files[0].path.split("/").last;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
        child: Container(
      height: 110,
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text("Uploading Document", style: TextStyle(fontSize: 18)),
          SizedBox(
            height: 20,
          ),
          CircularProgressIndicator()
        ],
      ),
    )),
  );

  FormData formData = new FormData.fromMap({
    "file": await MultipartFile.fromFile(file.path,
        filename: filename, contentType: new MediaType('file', '*/*')),
    "type": "file"
  });

  DioHelper.postImage(
          url: 'TeacherSession/TeacherUploadDocument',
          data: formData,
          query: {
            "TeacherId": TeacherId,
            "LessonId": LessonId,
            "DataDate": DateTime.now(),
            "UserId": CacheHelper.getData(key: 'userId')
          },
          lang: "en",
          token: "")
      .then((value) {
    print(value.data["data"]);
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    getData();
  }).onError((error, stackTrace) {
    print(error.toString());
  });

  // var croppedPath = await cropImage(pickedFile);
}
