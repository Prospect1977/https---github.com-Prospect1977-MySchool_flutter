import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:my_school/screens/paymob_creditcard_screen.dart';
import 'package:my_school/screens/paymob_kiosk_screen.dart';
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
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              option(
                widget: widget,
                title:
                    lang == "en" ? "Pay with Bank Card" : "الدفع ببطاقة البنك",
                image: "assets/images/credit_cards.png",
                lang: lang,
                on_Tap: () {
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
              ),
              SizedBox(
                height: 20,
              ),
              option(
                widget: widget,
                title: lang == "en" ? "Pay on Stores" : "الدفع في المتاجر",
                image: "assets/images/Store.png",
                lang: lang,
                on_Tap: () {
                  Navigator.of(context).pop();
                  navigateTo(
                      context,
                      PaymobKioskScreen(
                        StudentId: widget.StudentId,
                        Payment: widget.Payment,
                        SessionHeaderId: widget.SessionHeaderId,
                        LessonDescription: widget.LessonDescription,
                        LessonName: widget.LessonName,
                        TeacherName: widget.TeacherName,
                        dir: widget.dir,
                      ));
                },
              ),
            ]),
      ),
    );
  }
}

class option extends StatelessWidget {
  const option(
      {Key key,
      @required this.widget,
      @required this.title,
      @required this.image,
      @required this.lang,
      @required this.on_Tap()})
      : super(key: key);

  final PaymobOptionsScreen widget;
  final String title;
  final String lang;
  final String image;

  final Function on_Tap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          on_Tap();
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 100,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(5)),
          child: Directionality(
            textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(image, height: 75),
                SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 22, color: Colors.black.withOpacity(0.60)),
                ),
              ],
            ),
          ),
        ));
  }
}
