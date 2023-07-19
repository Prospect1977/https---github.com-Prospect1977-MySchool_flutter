import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/paymob.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobKioskScreen extends StatefulWidget {
  PaymobKioskScreen(
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
  State<PaymobKioskScreen> createState() => _PaymobKioskScreenState();
}

class _PaymobKioskScreenState extends State<PaymobKioskScreen> {
  bool isResponseRecieved = false;
  WebViewController webViewController;
  int bill_reference = 0;
  var lang = CacheHelper.getData(key: "lang");
  var fullName = CacheHelper.getData(key: "fullName");
  String phoneNumber = CacheHelper.getData(key: "phoneNumber");
  var email = CacheHelper.getData(key: "email");
  bool isLoaded = false;
  var token = CacheHelper.getData(key: "token");
  int OrderId = 0;
  void postPurchase(StudentId, SessionHeaderId) {
    DioHelper.postData(
            url: 'StudentPurchaseSession',
            data: {},
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              'TransactionId': OrderId,
              'DataDate': DateTime.now(),
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {}
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }

  Future<void> Request1() async {
    DioHelper.postData(
        url: '$base_paymob_url/auth/tokens',
        data: {"api_key": api_key}).then((value) {
      print('token_first:' + value.data['token']);
      token_first = value.data['token'];
      Request2();
    });
  }

  Future<void> Request2() async {
    print('assure token_first:' + token_first);
    DioHelper.postPaymobData(url: '$base_paymob_url/ecommerce/orders', data: {
      "auth_token": token_first,
      "delivery_needed": "false",
      "amount_cents": widget.Payment.toString(),
      "currency": "EGP",
//  "merchant_order_id": 5,
      "items": []
    }).then((value) {
      print('order id: ${value.data['id']}');
      setState(() {
        OrderId = value.data['id'];
      });

      Request3();
    });
  }

  Future<void> Request3() async {
    DioHelper.postPaymobData(
        url: '$base_paymob_url/acceptance/payment_keys',
        data: {
          "auth_token": token_first,
          "amount_cents": widget.Payment.toString(),
          "expiration": 3600,
          "order_id": OrderId.toString(),
          "billing_data": {
            "apartment": "NA",
            "email": email,
            "floor": "NA",
            "first_name": fullName.split(' ')[0],
            "street": "NA",
            "building": "NA",
            "phone_number": phoneNumber == null ? "6818189198" : phoneNumber,
            "shipping_method": "NA",
            "postal_code": "NA",
            "city": "NA",
            "country": "Egypt",
            "last_name": fullName.split(' ').length == 1
                ? "null"
                : fullName.split(' ')[1],
            "state": "NA"
          },
          "currency": "EGP",
          "integration_id": kiosk_integration_id, // very important
          "lock_order_when_paid": "false",
          "items": []
        }).then((t) {
      token_second = t.data['token'];
      print('token_second: ${t.data['token']}');
      postPurchase(
        widget.StudentId,
        widget.SessionHeaderId,
      );
      Request4();
    });
  }

  Future<void> Request4() async {
    DioHelper.postPaymobData(
        url: '$base_paymob_url/acceptance/payments/pay',
        data: {
          "source": {"identifier": "AGGREGATOR", "subtype": "AGGREGATOR"},
          "payment_token": token_second
        }).then((t) {
      print(t.data["data"]["bill_reference"]);
      setState(() {
        isLoaded = true;
        isResponseRecieved = true;
        bill_reference = t.data["data"]["bill_reference"];
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Request1();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Complete Payment" : "إستكمال الدفع"),
      body: isLoaded == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("كود الدفع",
                      style: TextStyle(fontSize: 26, color: Colors.black54)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    bill_reference.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        "إذهب بالكود إلى المتجر واخبرهم بأنك ترغب في الدفع عن طريق: Paymob accept، وسوف يتم تفعيل الدرس فور إتمام عملية الدفع",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  )
                ],
              )),
              isResponseRecieved
                  ? Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: defaultButton(
                            function: () {
                              Navigator.of(context).pop();
                              navigateTo(
                                  context,
                                  StudentSessionDetailsScreen(
                                      SessionHeaderId: widget.SessionHeaderId,
                                      LessonName: widget.LessonName,
                                      LessonDescription:
                                          widget.LessonDescription,
                                      dir: widget.dir,
                                      StudentId: widget.StudentId,
                                      TeacherName: widget.TeacherName));
                            },
                            text: lang == "en"
                                ? "Back to Lesson"
                                : "العودة إلى الدرس",
                            background: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                    )
                  : Container(),
            ]),
    );
  }
}
