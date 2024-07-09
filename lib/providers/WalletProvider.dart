import 'dart:convert';

import 'package:flutter/material.dart';

import '../shared/cache_helper.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';
import 'package:http/http.dart' as http;

class WalletProvider with ChangeNotifier {
  double walletBalance;
  get WalletBalance {
    return walletBalance;
  }

  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');

  bool isLoading = true;
  Future<void> getData(context) async {
    isLoading = true;
    var url = Uri.parse(
      '${baseUrl}Wallet/GetUserBalance?UserId=${CacheHelper.getData(key: 'userId')}',
    );
    var response = await http.get(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    var value = json.decode(response.body);
    print(value["data"]);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }
    walletBalance = double.parse(value["data"].toStringAsFixed(2));
    isLoading = false;
    notifyListeners();

    // await DioHelper.getData(
    //         url: "Wallet/GetUserBalance", query: {}, token: token, lang: lang)
    //     .then((value) {
    //   print(value.data);
    //   if (value.data["status"] == false &&
    //       value.data["message"] == "SessionExpired") {
    //     handleSessionExpired(context);
    //     return;
    //   } else if (value.data["status"] == false) {
    //     showToast(text: value.data["message"], state: ToastStates.ERROR);
    //     return;
    //   }
    //   walletBalance = double.parse(value.data["data"].toStringAsFixed(2));
    //   isLoading = false;
    //   notifyListeners();
    // }).catchError((error) {
    //   print(error.toString());
    //   showToast(text: error.toString(), state: ToastStates.ERROR);
    // });
  }
}
