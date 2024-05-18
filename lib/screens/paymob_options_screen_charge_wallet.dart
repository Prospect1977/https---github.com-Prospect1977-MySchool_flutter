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

class PaymobOptionsScreenChargeWallet extends StatefulWidget {
  PaymobOptionsScreenChargeWallet(this.Amount, {Key key}) : super(key: key);

  final double Amount;

  @override
  State<PaymobOptionsScreenChargeWallet> createState() =>
      _PaymobOptionsScreenChargeWalletState();
}

class _PaymobOptionsScreenChargeWalletState
    extends State<PaymobOptionsScreenChargeWallet> {
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
                title: lang == "en"
                    ? "Charge wallet with Bank Card"
                    : "شحن المحفظة ببطاقة البنك",
                image: "assets/images/credit_cards.png",
                lang: lang,
                on_Tap: () {
                  Navigator.of(context).pop();
                  navigateTo(
                      context,
                      PaymobCreditCardScreen(
                        ChargeWalletMode: true,
                        Payment: widget.Amount,
                      ));
                },
              ),
              SizedBox(
                height: 20,
              ),
              option(
                widget: widget,
                title: lang == "en"
                    ? "Charge wallet in Store"
                    : "شحن المحفظة في المتجر",
                image: "assets/images/Store.png",
                lang: lang,
                on_Tap: () {
                  Navigator.of(context).pop();
                  navigateTo(
                      context,
                      PaymobKioskScreen(
                        ChargeWalletMode: true,
                        Payment: widget.Amount,
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

  final PaymobOptionsScreenChargeWallet widget;
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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: lang == "ar" ? 22 : 19,
                        color: Colors.black.withOpacity(0.60)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
