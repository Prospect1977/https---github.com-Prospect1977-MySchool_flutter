import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;

class QuestionImageInput extends StatefulWidget {
  final Function onSelectImage;

  QuestionImageInput(this.onSelectImage);

  @override
  State<QuestionImageInput> createState() => _QuestionImageInputState();
}

class _QuestionImageInputState extends State<QuestionImageInput> {
  //----------------------------------------------------------------------
  Future<String> cropImage(XFile f) async {
    //final file = File(f.path);
    var result = await ImageCropper().cropImage(
      sourcePath: f.path,
      aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 2),
      aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
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
          context: context,
        ),
      ],
    );
    return result.path;
  }

//------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    setState(() {
      // if (widget.existImage != null) {
      //   _storedImage = widget.existImage;
      // }
    });
    Future<void> _takePicture(ImageSource s) async {
      XFile pickedFile = await ImagePicker().pickImage(
        source: s,
        maxWidth: 200,
      );
      if (pickedFile == null) {
        return;
      }
      String filename = await pickedFile.path.split("/").last;

      var croppedPath = await cropImage(pickedFile);
      FormData formData = new FormData.fromMap({
        "image": await MultipartFile.fromFile(croppedPath,
            filename: filename, contentType: new MediaType('file', '*/*')),
        "type": "file"
      });

      DioHelper.postImage(
              url: 'TeacherQuiz/UploadQuestionImage',
              data: formData,
              query: {},
              lang: "en",
              token: "")
          .then((value) {
        print(value.data["data"]);
        widget.onSelectImage(value.data["data"]);
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text("Camera"),
          onPressed: (() => _takePicture(ImageSource.camera)),
        ),
        TextButton.icon(
          icon: Icon(Icons.image),
          label: Text("Gallery"),
          onPressed: (() => _takePicture(ImageSource.gallery)),
        ),
      ],
    );
  }
}
