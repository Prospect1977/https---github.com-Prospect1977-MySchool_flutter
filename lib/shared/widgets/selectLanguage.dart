import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguageWidget extends StatefulWidget {
  String lange = lang;
  SelectLanguageWidget({@required this.lange, Key key}) : super(key: key);

  @override
  State<SelectLanguageWidget> createState() => _SelectLanguageWidgetState();
}

class _SelectLanguageWidgetState extends State<SelectLanguageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: Column(children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              widget.lange = "en";
            });
            // CacheHelper.init();
            CacheHelper.saveData(key: "lang", value: "en");
            lang = "en";
          },
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: defaultColor),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(children: [
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: defaultColor)),
                  child: Image.asset(
                    "assets/images/Flag_en.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    "English",
                    style: TextStyle(fontSize: 18, color: defaultColor),
                  ),
                ),
                Container(
                    width: 40,
                    child: widget.lange == "en"
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          )
                        : Container())
              ]),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              widget.lange = "ar";
            });
            //CacheHelper.init();
            CacheHelper.saveData(key: "lang", value: "ar");
            lang = "ar";
          },
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: defaultColor),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(children: [
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: defaultColor)),
                  child: Image.asset(
                    "assets/images/Flag_ar.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    "العربية",
                    style: TextStyle(fontSize: 18, color: defaultColor),
                  ),
                ),
                Container(
                    width: 40,
                    child: widget.lange == "ar"
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          )
                        : Container())
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
