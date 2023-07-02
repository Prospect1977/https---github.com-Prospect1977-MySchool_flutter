import 'package:flutter/material.dart';
import 'package:my_school/shared/cache_helper.dart';

class UnderConstructionScreen extends StatefulWidget {
  UnderConstructionScreen();
  static String routeName = '/bar_chart_screen';

  @override
  State<UnderConstructionScreen> createState() =>
      _UnderConstructionScreenState();
}

class _UnderConstructionScreenState extends State<UnderConstructionScreen> {
  String _filterBy = 'thisMonth';
  void _onFilterButtonClick(String Filter) {
    setState(() {
      _filterBy = Filter;
    });
  }

  var lang = CacheHelper.getData(key: "lang");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bar Chart'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  //Navigator.of(context).pushNamed(SearchExpense.routeName);
                },
                icon: Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.white,
                )),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Icon(
                Icons.construction,
                size: 100,
                color: Colors.black38,
              ),
            ),
            Text(
              lang == "en" ? 'Under Construction' : "قيد الإنشاء",
              style: TextStyle(color: Colors.black45, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
