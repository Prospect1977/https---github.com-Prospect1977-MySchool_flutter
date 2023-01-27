import 'package:flutter/material.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Salla',
        ),
      ),
      body: TextButton(
        onPressed: () {
          CacheHelper.removeData(
            key: 'token',
          ).then((value) {
            if (value) {
              navigateAndFinish(
                context,
                LoginScreen(),
              );
            }
          });
        },
        child: Text(
          'SIGN OUT',
        ),
      ),
    );
  }
}
