import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;

class TeacherImageInput extends StatefulWidget {
  final Function onSelectImage;
  bool isThereAnImage;
  TeacherImageInput(this.onSelectImage, this.isThereAnImage);

  @override
  State<TeacherImageInput> createState() => _TeacherImageInputState();
}

class _TeacherImageInputState extends State<TeacherImageInput> {
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  int TeacherId = CacheHelper.getData(key: "teacherId");
  //----------------------------------------------------------------------
  Future<String> cropImage(XFile f) async {
    //final file = File(f.path);
    var result = await ImageCropper().cropImage(
      sourcePath: f.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: defaultColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
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
    Future<void> _takePicture(ImageSource s, bool DeletePhoto) async {
      if (DeletePhoto) {
        showDialog(
            context: context,
            builder: (ctx) => Directionality(
                textDirection:
                    lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                child: AlertDialog(
                  titleTextStyle: TextStyle(
                      color: defaultColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  title: Text(lang == "en" ? 'Are you sure?' : "هل انت متأكد؟"),
                  content: Text(
                    lang == "en"
                        ? 'Are you sure that you want to remove this question?'
                        : "هل تريد حذف هذا السؤال؟",
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(lang == "en" ? "No" : "لا"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: Text(lang == "en" ? 'Yes' : "نعم"),
                      onPressed: () {
                        DioHelper.postImage(
                                url: 'TeacherProfile/UpdatePhoto',
                                data: {},
                                query: {
                                  'TeacherId': TeacherId,
                                  "DeletePhoto": true
                                },
                                lang: lang,
                                token: token)
                            .then((value) {
                          print(value.data["data"]);
                          if (value.data["status"] == false) {
                            navigateAndFinish(context, LoginScreen());
                          }
                          widget.onSelectImage(value.data["data"]);
                          Navigator.of(ctx).pop();
                          setState(() {
                            widget.isThereAnImage = false;
                          });
                          return;
                        }).onError((error, stackTrace) {
                          print(error.toString());
                          return;
                        });
                      },
                    ),
                  ],
                )));

        return;
      }
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
              url: 'TeacherProfile/UpdatePhoto',
              data: formData,
              query: {'TeacherId': TeacherId, "DeletePhoto": false},
              lang: lang,
              token: token)
          .then((value) {
        print(value.data["data"]);
        if (value.data["status"] == false) {
          navigateAndFinish(context, LoginScreen());
        }
        widget.onSelectImage(value.data["data"]);
        setState(() {
          widget.isThereAnImage = true;
        });
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }

    return Column(
      children: [
        Divider(
          thickness: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.black45),
                onPressed: (() => _takePicture(ImageSource.camera, false)),
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.image, color: Colors.black45),
                onPressed: (() => _takePicture(ImageSource.gallery, false)),
              ),
            ),
            widget.isThereAnImage
                ? Expanded(
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.black45),
                      onPressed: (() =>
                          _takePicture(ImageSource.gallery, true)),
                    ),
                  )
                : Container(),
          ],
        ),
        Divider(
          thickness: 1,
        ),
      ],
    );
  }
}
