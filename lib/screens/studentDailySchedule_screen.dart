import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_school/cubits/StudentDailySchedule_cubit.dart';
import 'package:my_school/cubits/StudentDailySchedule_states.dart';
import 'package:my_school/models/StudentDailySchedule_model.dart';
import 'package:my_school/screens/studentLessonDetails_screen.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentDailyScheduleScreen extends StatefulWidget {
  final int Id;
  final String FullName;
  const StudentDailyScheduleScreen(this.Id, this.FullName);

  @override
  State<StudentDailyScheduleScreen> createState() =>
      _StudentDailyScheduleScreenState();
}

class _StudentDailyScheduleScreenState
    extends State<StudentDailyScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();
    var TodaysDateIndex = 0;
    final ItemScrollController _itemScrollController = ItemScrollController();
    final ItemScrollController _itemScrollControllerLeft =
        ItemScrollController();

    String AppBarTitle() {
      var role = CacheHelper.getData(key: "roles");
      if (role == "Student") {
        return lang == "en" ? "Daily Schedule" : "الجدول اليومي";
      } else {
        return widget.FullName.split(" ")[0];
      }
    }

    return Scaffold(
        appBar: appBarComponent(context, AppBarTitle()),
        body: BlocProvider(
            create: (context) =>
                StudentDailyScheduleCubit()..getData(widget.Id),
            child: BlocConsumer<StudentDailyScheduleCubit,
                StudentDailyScheduleStates>(listener: (context, state) {
              if (state is UnAuthendicatedState) {
                navigateTo(context, LoginScreen());
              }
            }, builder: (context, state) {
              var cubit = StudentDailyScheduleCubit.get(context);
              List<GlobalKey> dKeys = [];
              List<GlobalKey> sKeys = [];
              if (cubit.DailySchedule != null) {
                dKeys =
                    cubit.DailySchedule.items.map((e) => GlobalKey()).toList();
                sKeys =
                    cubit.DailySchedule.items.map((e) => GlobalKey()).toList();
                //_scrollToIndex(3, _itemScrollController);

              }
              TodaysDateIndex = cubit.TodaysDateIndex;
              return cubit.DailySchedule == null
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Row(
                        children: [
                          Padding(
                            /*----------------------------------------------------------Left Column*/
                            padding: const EdgeInsets.only(right: 3),
                            child: Container(
                                width: 55,
                                child: ScrollablePositionedList.builder(
                                  initialAlignment: 0.5,
                                  itemScrollController:
                                      _itemScrollControllerLeft,
                                  initialScrollIndex: TodaysDateIndex,
                                  itemCount: cubit.DailySchedule.items.length,
                                  itemBuilder: (context, index) {
                                    var item = cubit.DailySchedule.items[index];
                                    return InkWell(
                                      onTap: () {
                                        _scrollToIndex(
                                            index, _itemScrollController);
                                        setState(() {
                                          TodaysDateIndex = index;
                                          print(TodaysDateIndex);
                                        });
                                      },
                                      child: Container(
                                        key: dKeys[index],
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black26
                                                        : Colors.black26),
                                                top: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black26
                                                        : Colors.black26),
                                                right: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black26
                                                        : Colors.black26)),
                                            color: index == TodaysDateIndex
                                                ? defaultColor
                                                : item.isHoliday
                                                    ? Colors.black26
                                                    : Colors.white),
                                        child: Column(children: [
                                          Text(
                                            DateFormat("EEE")
                                                .format(item.dataDate),
                                            style: TextStyle(
                                                color: index == TodaysDateIndex
                                                    ? Colors.white
                                                    : item.isHoliday
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            DateFormat("d MMM")
                                                .format(item.dataDate),
                                            style: TextStyle(
                                                color: index == TodaysDateIndex
                                                    ? Colors.white
                                                    : item.isHoliday
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                fontSize: 12),
                                          )
                                        ]),
                                      ),
                                    );
                                  },
                                )),
                          ),
                          Expanded(
                              /*----------------------------------------------------------Right Column*/
                              child: ScrollablePositionedList.builder(
                                  itemScrollController: _itemScrollController,
                                  initialScrollIndex: TodaysDateIndex,
                                  itemCount: cubit.DailySchedule.items.length,
                                  itemBuilder: ((context, index) {
                                    var item = cubit.DailySchedule.items[index];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  100),
                                          child: Container(
                                            //Main Container block
                                            width: double.infinity,
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              // borderRadius: BorderRadius.circular(7),
                                              border: Border.all(
                                                  color: defaultColor),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  //Date title
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: defaultColor,
                                                      border: Border.all(
                                                          color: defaultColor),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              /*topLeft: Radius.circular(7),
                              topRight: Radius.circular(7)*/
                                                              )),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.calendar_month,
                                                          color: Colors.white),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        DateFormat("EEEE d MMM")
                                                            .format(
                                                                item.dataDate),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // SizedBox(
                                                //   height: 5,
                                                // ),
                                                item.isHoliday
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .blue.shade100,
                                                            borderRadius: BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        5))),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height -
                                                            135,
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/Holiday.png",
                                                              width: 150,
                                                              height: 150,
                                                            ),
                                                            Text(
                                                              item.holidayName,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 24,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          228,
                                                                          100,
                                                                          100),
                                                                  shadows: <
                                                                      Shadow>[
                                                                    Shadow(
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              0),
                                                                      blurRadius:
                                                                          3,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : ListView.builder(
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            item.lessons.length,
                                                        itemBuilder: (context,
                                                                index) =>
                                                            mainSubListItem(
                                                                context,
                                                                item.lessons[
                                                                    index]),
                                                      )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  })))
                        ],
                      ),
                    );
            })));
  }
}

Widget mainSubListItem(context, Lesson l) {
  return InkWell(
    onTap: () {
      navigateTo(context, StudentLessonDetailsScreen(l.lessonId, l.lessonName));
    },
    child: l.lessonName == null
        ? Container()
        : Card(
            elevation: 2,
            child: Column(
              children: [
                Container(
                  //Subject name
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  child: Text(
                    l.subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: l.dir == "ltr"
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 245, 245, 245),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: l.parentLessonName == null
                      ? Text(
                          l.lessonName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Column(
                          //if the lesson has a parent
                          crossAxisAlignment: l.dir == "ltr"
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              l.parentLessonName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            l.dir == "rtl"
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3),
                                          child: Text(
                                            l.lessonName,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_return,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Transform.scale(
                                        scaleX: -1,
                                        child: Icon(
                                          Icons.keyboard_return,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3),
                                          child: Text(
                                            l.lessonName,
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ), //End if the lesson has a parent
                ),
              ],
            )),
  );
}

void _scrollToIndex(int index, _itemScrollController) {
  // try {
  _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic);
  // } catch (ex) {
  //   //   _itemScrollController.scrollTo(
  //   //       index: index - 1,
  //   //       duration: const Duration(seconds: 2),
  //   //       curve: Curves.easeInOutCubic);
  // }
}
