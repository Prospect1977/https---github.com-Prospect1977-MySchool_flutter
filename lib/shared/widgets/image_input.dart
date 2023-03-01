import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  File existImage;
  ImageInput(this.onSelectImage, this.existImage);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;

  @override
  Widget build(BuildContext context) {
    setState(() {
      // if (widget.existImage != null) {
      //   _storedImage = widget.existImage;
      // }
    });
    Future<void> _takePicture(ImageSource s) async {
      final imageFile = await ImagePicker().pickImage(
        source: s,
        maxWidth: 200,
      );
      if (imageFile == null) {
        return;
      }
      String filename = await imageFile.path.split("/").last;
      FormData formData = new FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path,
            filename: filename, contentType: new MediaType('file', '*/*')),
        "type": "file"
      });

      DioHelper.postImage(
              url: 'UploadTest',
              data: formData,
              query: {},
              lang: "en",
              token: "")
          .then((value) {
        print(value.data);
      });
      setState(() {
        //_storedImage = File(imageFile.path);
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: _storedImage != null
              ? Image.file(
                  _storedImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Text("No Image Selected"),
          alignment: Alignment.center,
        ),
        // IconButton(
        //     icon: Icon(Icons.delete),
        //     onPressed: () {
        //       setState(() {
        //         _storedImage = null;
        //         widget.existImage = null;
        //       });
        //       widget.onSelectImage(null);
        //     }),
        Column(
          children: [
            TextButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Take a photo"),
              onPressed: (() => _takePicture(ImageSource.camera)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              label: Text("Select a photo"),
              onPressed: (() => _takePicture(ImageSource.gallery)),
            ),
          ],
        )
      ],
    );
  }
}
