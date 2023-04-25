import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';

class ProgressDialogWidget extends StatefulWidget {
  const ProgressDialogWidget({Key key}) : super(key: key);

  @override
  State<ProgressDialogWidget> createState() => _ProgressDialogWidgetState();
}

class _ProgressDialogWidgetState extends State<ProgressDialogWidget> {
  Subscription subscription;
  double progress = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        this.progress = progress;
      });
    });
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    subscription.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = progress == null ? 0 : progress / 100;
    return /*progress == 1
        ? Container
        :*/
        Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value < 1 ? 'Processing Video...' : 'Uploading Video...',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 24,
          ),
          value < 1
              ? LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                )
              : CircularProgressIndicator(),
          value < 1
              ? Text('${(value * 100).toStringAsFixed(0)} %')
              : Container(),
          SizedBox(
            height: 16,
          ),
          value < 1
              ? ElevatedButton(
                  onPressed: () {
                    VideoCompress.cancelCompression();
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"))
              : Container()
        ],
      ),
    );
  }
}
