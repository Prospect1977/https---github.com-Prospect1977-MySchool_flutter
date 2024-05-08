import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;

class ImageInputTicket extends StatefulWidget {
  final Function onSelectImage;
  File existImage;

  ImageInputTicket(this.onSelectImage, this.existImage);

  @override
  State<ImageInputTicket> createState() => _ImageInputTicketState();
}

class _ImageInputTicketState extends State<ImageInputTicket> {
  File _storedImage;
  String lang = CacheHelper.getData(key: "lang");
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
              url: 'Ticket/UploadImage',
              data: formData,
              query: {},
              lang: "en",
              token: "")
          .then((value) {
        print(value.data);
        widget.onSelectImage(value.data);
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
      });
      setState(() {
        _storedImage = File(imageFile.path);
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _storedImage != null
            ? Stack(children: [
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
                      : Container(),
                  alignment: Alignment.center,
                ),
                IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _storedImage = null;
                        widget.existImage = null;
                      });
                      widget.onSelectImage(null);
                    }),
              ])
            : Container(),
        _storedImage == null
            ? TextButton.icon(
                icon: Icon(Icons.image),
                label: Text(
                    lang == "en" ? "Attach a photo" : "إرفاق صورة توضيحية"),
                onPressed: (() => _takePicture(ImageSource.gallery)),
              )
            : Container()
      ],
    );
  }
}
