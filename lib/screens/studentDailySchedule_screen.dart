import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:my_school/cubits/StudentDailySchedule_cubit.dart';
import 'package:my_school/cubits/StudentDailySchedule_states.dart';
import 'package:my_school/models/StudentDailySchedule_model.dart';
import 'package:my_school/screens/studentLessonSessions_screen.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentDailyScheduleScreen extends StatefulWidget {
  final int Id;
  final String FullName;

  StudentDailyScheduleScreen(this.Id, this.FullName);
  int SelectedDateIndex = 0;
  @override
  State<StudentDailyScheduleScreen> createState() =>
      _StudentDailyScheduleScreenState();
}

class _StudentDailyScheduleScreenState
    extends State<StudentDailyScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    var lang = CacheHelper.getData(key: "lang").toString().toLowerCase();

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
              widget.SelectedDateIndex = cubit.TodaysDateIndex;

              if (state is UnAuthendicatedState) {
                navigateAndFinish(context, LoginScreen());
              }
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
                                  initialScrollIndex: widget.SelectedDateIndex,
                                  itemCount: cubit.DailySchedule.items.length,
                                  itemBuilder: (context, index) {
                                    var item = cubit.DailySchedule.items[index];
                                    return InkWell(
                                      onTap: () {
                                        _scrollToIndex(
                                            index, _itemScrollController);
                                        setState(() {
                                          cubit.TodaysDateIndex = index;
                                          widget.SelectedDateIndex = index;
                                        });
                                      },
                                      child: Container(
                                        key: dKeys[index],
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black38
                                                        : Colors.black54),
                                                top: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black38
                                                        : Colors.black54),
                                                right: BorderSide(
                                                    color: item.isHoliday
                                                        ? Colors.black38
                                                        : Colors.black54)),
                                            color: index ==
                                                    widget.SelectedDateIndex
                                                ? Colors.deepPurple
                                                : item.isHoliday
                                                    ? Colors.black26
                                                    : Colors.white),
                                        child: Column(children: [
                                          Text(
                                            intl.DateFormat("EEE")
                                                .format(item.dataDate),
                                            style: TextStyle(
                                              color: index ==
                                                      widget.SelectedDateIndex
                                                  ? Colors.white
                                                  : item.isHoliday
                                                      ? Colors.white70
                                                      : Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            intl.DateFormat("d MMM")
                                                .format(item.dataDate),
                                            style: TextStyle(
                                                color: index ==
                                                        widget.SelectedDateIndex
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
                                  initialScrollIndex: widget.SelectedDateIndex,
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
                                                  color: index ==
                                                          widget
                                                              .SelectedDateIndex
                                                      ? Colors.deepPurple
                                                      : defaultColor),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  //Date title
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: index ==
                                                              widget
                                                                  .SelectedDateIndex
                                                          ? Colors.deepPurple
                                                          : Colors.deepPurple,
                                                      border: Border.all(
                                                          color: index ==
                                                                  widget
                                                                      .SelectedDateIndex
                                                              ? Colors
                                                                  .deepPurple
                                                              : Colors
                                                                  .deepPurple),
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
                                                        intl.DateFormat(
                                                                "EEEE d MMM")
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
                                                SizedBox(
                                                  height: 5,
                                                ),
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
                                                                    index],
                                                                widget.Id),
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

Widget mainSubListItem(context, Lesson l, studentId) {
  return InkWell(
      onTap: () {
        navigateTo(
            context,
            StudentLessonSessionsScreen(studentId, l.lessonId, l.lessonName,
                l.lessonDescription, l.yearSubjectId, l.dir));
      },
      child: l.lessonName == null
          ? Container()
          : Directionality(
              textDirection:
                  l.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          l.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black.withOpacity(.8)),
                        ),
                      ),
                      l.parentLessonName != null
                          ? Text(
                              l.parentLessonName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7)),
                            )
                          : Container(),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        l.lessonName,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.6), fontSize: 15),
                      ),
                      l.studentCompleted != 0
                          ? SizedBox(
                              height: 8,
                            )
                          : Container(),
                      l.studentCompleted != 0
                          ? Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                children: [
                                  Container(
                                    width: 25,
                                    child: Text(
                                      l.studentCompleted > 100
                                          ? "100"
                                          : '${l.studentCompleted.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(255, 0, 88, 3)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        height: 3,
                                        child: Stack(
                                          children: [
                                            FractionallySizedBox(
                                              child: Container(
                                                  color: Colors.green),
                                              widthFactor:
                                                  l.studentCompleted / 100,
                                              heightFactor: 1,
                                            ),
                                            Container(color: Colors.black12),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Divider(
                        thickness: 2,
                        color: Colors.deepPurple.withOpacity(0.15),
                      )
                    ],
                  )),
            ));
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
