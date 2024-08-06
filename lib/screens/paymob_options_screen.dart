import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:my_school/providers/StudentLessonSessionsProvider.dart';
import 'package:my_school/providers/StudentVideo_provider.dart';
import 'package:my_school/providers/WalletProvider.dart';
import 'package:my_school/screens/paymob_creditcard_screen.dart';
import 'package:my_school/screens/paymob_kiosk_screen.dart';
import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/screens/wallet_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../shared/components/functions.dart';

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
  dynamic Payment;
  final String LessonName;
  final String LessonDescription;
  final String dir;
  final String TeacherName;

  @override
  State<PaymobOptionsScreen> createState() => _PaymobOptionsScreenState();
}

class _PaymobOptionsScreenState extends State<PaymobOptionsScreen> {
  var lang = CacheHelper.getData(key: "lang");
  bool _isIOS = CacheHelper.getData(key: 'isIOS');
  bool isProcessing = false; //for wallet payment option:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Payment Method" : "طريقة الدفع"),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Directionality(
          textDirection: lang == "en" ? TextDirection.ltr : TextDirection.rtl,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isIOS)
                  option(
                    widget: widget,
                    title: lang == "en"
                        ? "Pay with Bank Card"
                        : "الدفع ببطاقة البنك",
                    image: "assets/images/credit_cards.png",
                    lang: lang,
                    on_Tap: () {
                      Navigator.of(context).pop();
                      navigateTo(
                          context,
                          PaymobCreditCardScreen(
                            ChargeWalletMode: false,
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
                if (!_isIOS)
                  SizedBox(
                    height: 20,
                  ),
                if (!_isIOS)
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
                            ChargeWalletMode: false,
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
                if (!_isIOS)
                  SizedBox(
                    height: 20,
                  ),
                FutureBuilder(
                    future: Provider.of<WalletProvider>(context, listen: false)
                        .getData(context),
                    builder: ((context, snapshot) =>
                        Consumer<WalletProvider>(builder: (ctx, model, child) {
                          return model.isLoading == true || isProcessing == true
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : option(
                                  widget: widget,
                                  title: lang == "en"
                                      ? "From Wallet (Credit: ${model.WalletBalance.toStringAsFixed(0)} EGP)"
                                      : "من المحفظة (الرصيد:  ${ConvertNumberToHindi(model.walletBalance.toStringAsFixed(0))} ج.م)",
                                  image: "assets/images/wallet-color.png",
                                  lang: lang,
                                  on_Tap: () {
                                    //Navigator.of(context).pop();
                                    double paymentFinal = widget.Payment / 100;
                                    print(paymentFinal);
                                    double wallBalance =
                                        model.walletBalance.toDouble();
                                    if (wallBalance >= paymentFinal) {
                                      setState(() {
                                        isProcessing = true;
                                      });

                                      DioHelper.postData(
                                          url:
                                              'StudentPurchaseSession/PurchaseSessionFromWallet',
                                          lang: lang,
                                          token: token,
                                          query: {
                                            "StudentId": widget.StudentId,
                                            "SessionHeaderId":
                                                widget.SessionHeaderId,
                                            "DataDate": DateTime.now()
                                          }).then((value) {
                                        setState(() {
                                          isProcessing = false;
                                        });
                                        if (value.data["status"] == false &&
                                            value.data["message"] ==
                                                "SessionExpired") {
                                          handleSessionExpired(context);
                                          return;
                                        } else if (value.data["status"] ==
                                            false) {
                                          showToast(
                                              text: value.data["message"],
                                              state: ToastStates.ERROR);
                                          return;
                                        }

                                        //update the wallet provider
                                        Provider.of<WalletProvider>(context,
                                                listen: false)
                                            .getData(
                                          context,
                                        );
                                        int lessonId = value.data["data"];
                                        Provider.of<StudentLessonSessionsProvider>(
                                                context,
                                                listen: false)
                                            .getSessions(context,
                                                widget.StudentId, lessonId);
                                        //close the page
                                        Navigator.of(context).pop();
                                        //navigate to student session details screen
                                        navigateTo(
                                            context,
                                            StudentSessionDetailsScreen(
                                                SessionHeaderId:
                                                    widget.SessionHeaderId,
                                                LessonName: widget.LessonName,
                                                LessonDescription:
                                                    widget.LessonDescription,
                                                dir: widget.dir,
                                                StudentId: widget.StudentId,
                                                TeacherName:
                                                    widget.TeacherName));
                                      }).catchError((error) {
                                        setState(() {
                                          isProcessing = false;
                                        });
                                        showToast(
                                            text: error.toString(),
                                            state: ToastStates.ERROR);
                                      });
                                    } else {
                                      navigateTo(context, WalletScreen());
                                    }
                                  },
                                );
                        }))),
                Row(children: [
                  TextButton.icon(
                      onPressed: () {
                        navigateTo(context, WalletScreen());
                      },
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color: Colors.green,
                      ),
                      label: Text(
                        lang == "en" ? "Charge wallet" : "شحن المحفظة",
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ))
                ]),
              ]),
        ),
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 20, color: Colors.black.withOpacity(0.60)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
