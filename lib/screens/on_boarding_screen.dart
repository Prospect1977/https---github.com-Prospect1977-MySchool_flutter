import 'package:flutter/material.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/widgets/selectLanguage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/styles/colors.dart';

class BoardingModel {
  final String image;
  final String title;
  final String body;
  Widget widget;
  BoardingModel({
    this.title,
    this.image,
    this.body,
    this.widget,
  });
}

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var boardController = PageController();
  bool loading = false;
  //var lang = CacheHelper.getData(key: "lang");
  List<BoardingModel> boarding = [
    BoardingModel(
        image: 'assets/images/onboard_1.png',
        widget: SelectLanguageWidget(
          lange: lang,
        )),
    BoardingModel(
      image: 'assets/images/onboard_3.png',
      title: 'Study any time ',
      body: 'With your favorite teacher',
    ),
    BoardingModel(
      image: 'assets/images/onboard_2.png',
      title: 'Follow up',
      body: 'Monitor your child activity day by day',
    ),
  ];

  bool isLast = false;

  void submit() {
    //o CacheHelper.saveData(key: "lang", value: "ar");
    setState(() {
      loading = true;
    });
    CacheHelper.saveData(
      key: 'onBoarding',
      value: true,
    ).then((value) {
      if (value) {
        navigateAndFinish(
          context,
          LoginScreen(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Container(
            color: Colors.white,
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: defaultTextButton(
                      function: submit,
                      text: 'skip',
                      fontSize: 16.1,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: boardController,
                    onPageChanged: (int index) {
                      if (index == boarding.length - 1) {
                        setState(() {
                          isLast = true;
                        });
                      } else {
                        setState(() {
                          isLast = false;
                        });
                      }
                    },
                    itemBuilder: (context, index) =>
                        buildBoardingItem(boarding[index]),
                    itemCount: boarding.length,
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  children: [
                    SmoothPageIndicator(
                      controller: boardController,
                      effect: ExpandingDotsEffect(
                        dotColor: Colors.grey,
                        activeDotColor: defaultColor,
                        dotHeight: 10,
                        expansionFactor: 4,
                        dotWidth: 10,
                        spacing: 5.0,
                      ),
                      count: boarding.length,
                    ),
                    Spacer(),
                    FloatingActionButton(
                      onPressed: () {
                        if (isLast) {
                          submit();
                        } else {
                          boardController.nextPage(
                            duration: Duration(
                              milliseconds: 750,
                            ),
                            curve: Curves.fastLinearToSlowEaseIn,
                          );
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget buildBoardingItem(BoardingModel model) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image(
              image: AssetImage('${model.image}'),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          model.widget != null ? model.widget : Container(),
          model.title != null
              ? Text(
                  '${model.title}',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: defaultColor,
                      decoration: TextDecoration.none),
                )
              : Container(),
          SizedBox(
            height: model.title != null ? 15.0 : 0.1,
          ),
          model.body != null
              ? Text(
                  '${model.body}',
                  style: TextStyle(
                      fontSize: 14.0,
                      color: defaultColor,
                      decoration: TextDecoration.none),
                )
              : Container(),
          SizedBox(
            height: 30.0,
          ),
        ],
      );
}
