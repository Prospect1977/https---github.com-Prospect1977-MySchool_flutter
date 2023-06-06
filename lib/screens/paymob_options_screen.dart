import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:my_school/screens/paymob_creditcard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobOptionsScreen extends StatefulWidget {
  PaymobOptionsScreen(
      {@required this.StudentId,
      @required this.SessionHeaderId,
      @required this.Payment,
      @required this.LessonName,
      @required this.LessonDescription,
      @required this.dir,
      @required this.TeacherName,
      Key key})
      : super(key: key);
  final int StudentId;
  final int SessionHeaderId;
  final dynamic Payment;
  final String LessonName;
  final String LessonDescription;
  final String dir;
  final String TeacherName;

  @override
  State<PaymobOptionsScreen> createState() => _PaymobOptionsScreenState();
}

class _PaymobOptionsScreenState extends State<PaymobOptionsScreen> {
  var lang = CacheHelper.getData(key: "lang");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Payment Method" : "طريقة الدفع"),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          InkWell(
              onTap: () {
                Navigator.of(context).pop();
                navigateTo(
                    context,
                    PaymobCreditCardScreen(
                      StudentId: widget.StudentId,
                      Payment: widget.Payment,
                      SessionHeaderId: widget.SessionHeaderId,
                      LessonDescription: widget.LessonDescription,
                      LessonName: widget.LessonName,
                      TeacherName: widget.TeacherName,
                      dir: widget.dir,
                    ));
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  "Credit Card",
                  style: TextStyle(fontSize: 20),
                ),
              )),
          SizedBox(
            height: 10,
          ),
          InkWell(
              onTap: () {
                Navigator.of(context).pop();
                navigateTo(
                    context,
                    PaymobCreditCardScreen(
                      StudentId: widget.StudentId,
                      Payment: widget.Payment,
                      SessionHeaderId: widget.SessionHeaderId,
                      LessonDescription: widget.LessonDescription,
                      LessonName: widget.LessonName,
                      TeacherName: widget.TeacherName,
                      dir: widget.dir,
                    ));
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  "Pay Later",
                  style: TextStyle(fontSize: 20),
                ),
              )),
        ]),
      ),
    );
  }
}
