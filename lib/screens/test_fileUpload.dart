import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/widgets/image_input.dart';
import 'dart:io' as i;

class TestFileUpload extends StatefulWidget {
  const TestFileUpload({Key key}) : super(key: key);

  @override
  State<TestFileUpload> createState() => _TestFileUploadState();
}

class _TestFileUploadState extends State<TestFileUpload> {
  i.File _pickedImage;
  i.File _existImage = null;
  void _selectImage(i.File pickedImage) {
    _pickedImage = pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, "upload"),
      body: Container(
        child: ImageInput(_selectImage, _existImage),
      ),
    );
  }
}
