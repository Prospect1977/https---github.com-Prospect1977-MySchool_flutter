import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/screens/paymob_options_screen_charge_wallet.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:provider/provider.dart';

import '../providers/WalletProvider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  var lang = CacheHelper.getData(key: 'lang');
  bool showChargeForm = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController AmountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Provider.of<WalletProvider>(context, listen: false)
              .getData(context),
          builder: ((context, snapshot) =>
              Consumer<WalletProvider>(builder: (ctx, model, child) {
                return model.isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Directionality(
                                  textDirection: lang == "en"
                                      ? TextDirection.ltr
                                      : TextDirection.ltr,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue.shade400,
                                    radius: 75,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue.shade300,
                                      backgroundImage: AssetImage(
                                        'assets/images/money-background.png',
                                      ),
                                      radius: 72,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/wallet.png',
                                            width: 60,
                                          ),
                                          Text(
                                            lang == "en"
                                                ? "${model.WalletBalance.toStringAsFixed(0)} EGP"
                                                : "${ConvertNumberToHindi(model.walletBalance.toStringAsFixed(0))} ج.م ",
                                            textDirection: lang == "en"
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            style: TextStyle(
                                              fontSize: lang == 'ar' ? 32 : 26,
                                              color: Colors.white,
                                              textBaseline:
                                                  TextBaseline.ideographic,
                                            ),
                                            textAlign: lang == "en"
                                                ? TextAlign.left
                                                : TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                if (!showChargeForm)
                                  MaterialButton(
                                      child: Text(
                                        lang == "en"
                                            ? "Charge Wallet"
                                            : "شحن المحفظة",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: lang == "ar" ? 22 : 18),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showChargeForm = true;
                                        });
                                      },
                                      color: Colors.green),
                                if (showChargeForm)
                                  Form(
                                    key: formKey,
                                    child: Column(children: [
                                      defaultFormField(
                                        controller: AmountController,
                                        type: TextInputType.number,
                                        validate: (value) {
                                          if (int.parse(value) < 10) {
                                            return lang == "en"
                                                ? "Amount must be at least 10 EGP"
                                                : "مبلغ الشحن لا يجب أن يقل عن 10 ج.م";
                                          }
                                          return null;
                                        },
                                        label:
                                            lang == 'ar' ? "المبلغ" : "Amount",
                                        prefix: Icons.account_circle,
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      defaultButton(
                                        function: () {
                                          if (formKey.currentState.validate()) {
                                            Navigator.of(context).pop();
                                            navigateTo(
                                                context,
                                                PaymobOptionsScreenChargeWallet(
                                                    double.parse(
                                                            AmountController
                                                                .text) *
                                                        100));
                                          }
                                        },
                                        borderRadius: 5,
                                        background: Colors.green,
                                        text: lang == "en" ? "Ok" : "موافق",
                                        isUpperCase: false,
                                      ),
                                    ]),
                                  ),
                              ]),
                        ),
                      );
              }))),
    );
  }
}
