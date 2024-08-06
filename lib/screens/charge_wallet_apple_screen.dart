import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:my_school/screens/wallet_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../providers/WalletProvider.dart';

class ChargeWalletAppleScreen extends StatefulWidget {
  @override
  _ChargeWalletAppleScreenState createState() =>
      _ChargeWalletAppleScreenState();
}

class _ChargeWalletAppleScreenState extends State<ChargeWalletAppleScreen> {
  List<StoreProduct> _products = [];
  //List<storeProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void processPayment(int price) {
    Provider.of<WalletProvider>(context, listen: false)
        .ChargeWalletApple(price, context)
        .then((value) {});
  }

  void _fetchProducts() async {
    try {
      List<StoreProduct> products = await Purchases.getProducts(
          ["product_identifier1", "product_identifier2"]);

      setState(() {
        _products = products;
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  void _purchaseProduct(String productIdentifier, price) async {
    try {
      CustomerInfo customerInfo =
          await Purchases.purchaseProduct(productIdentifier);
      print("Purchase successful for product: ${price}");
      processPayment(price);
    } catch (e) {
      if (e is PurchasesErrorCode) {
        print("Purchase failed: ${e.toString()}");
      } else {
        print("Purchase failed: $e");
      }
    }
  }

  void _restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      print("Purchases restored");
    } catch (e) {
      print("Restore failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "ar" ? "شحن المحفظة" : "Charge Wallet"),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 40,
              mainAxisSpacing: 40),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return InkWell(
              onTap: () => _purchaseProduct(product.identifier, product.price),
              child: Material(
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: defaultColor.withOpacity(.7))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${product.price.toString()}',
                        style: TextStyle(
                            fontSize: 25, color: defaultColor.shade700),
                      ),
                      Text(
                        lang == "en" ? "EGP" : "ج.م",
                        style: TextStyle(
                            fontSize: 20, color: defaultColor.withOpacity(.7)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class storeProduct {
  String title;
  String priceString;
  String identifier;
  int price;
  storeProduct({this.title, this.priceString, this.identifier, this.price});
}
