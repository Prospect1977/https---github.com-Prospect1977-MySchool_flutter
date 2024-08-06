import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:my_school/screens/wallet_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<StoreProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void processPayment(double price) {
    //StudentPurchaseSession/ChargeWalletApple(String UserId,double Amount,DateTime DataDate)
    DioHelper.postData(
            url: 'StudentPurchaseSession/ChargeWalletApple',
            query: {
              'UserId': CacheHelper.getData(key: 'userId'),
              'Amount': price,
              'DataDate': DateTime.now()
            },
            token: CacheHelper.getData(key: 'token'),
            lang: CacheHelper.getData(key: 'lang'))
        .then((value) {
      Navigator.of(context).pop();
      navigateTo(context, WalletScreen());
    });
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
      appBar: AppBar(
        title: Text("Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: _restorePurchases,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.priceString),
            trailing: ElevatedButton(
              onPressed: () =>
                  _purchaseProduct(product.identifier, product.price),
              child: Text("Buy"),
            ),
          );
        },
      ),
    );
  }
}
