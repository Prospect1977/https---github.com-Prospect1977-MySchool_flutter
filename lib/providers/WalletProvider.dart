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
  }

  Future<void> ChargeWalletApple(int Amount, context) async {
    isLoading = true;
    notifyListeners();
    var userId = CacheHelper.getData(key: 'userId');

    final url = Uri.parse(
      '${baseUrl}StudentPurchaseSession/ChargeWalletApple?Amount=$Amount&UserId=$userId&DataDate=${DateTime.now()}',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      showToast(text: value["message"], state: ToastStates.SUCCESS);
      Navigator.of(context).pop();
    }
    walletBalance = double.parse(value["data"].toStringAsFixed(2));
    isLoading = false;
    notifyListeners();
  }
}
