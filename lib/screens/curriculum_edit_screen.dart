import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:my_school/models/admin_lesson.dart';
import 'package:my_school/providers/CurriculumProvider.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:provider/provider.dart';

import '../shared/styles/colors.dart';
import 'curriculum_lesson_details_screen.dart';

class CurriculumEditScreen extends StatefulWidget {
  CurriculumEditScreen({
    this.TermIndex,
    this.YearSubjectId,
    this.dir,
    Key key,
  }) : super(key: key);
  final int TermIndex;
  final int YearSubjectId;
  final String dir;
  @override
  State<CurriculumEditScreen> createState() => _CurriculumEditScreenState();
}

class _CurriculumEditScreenState extends State<CurriculumEditScreen> {
  void DeleteLesson(id) async {
    await Provider.of<CurriculumProvider>(context, listen: false)
        .DeleteLesson(id);
    Provider.of<CurriculumProvider>(context, listen: false)
        .getData(widget.YearSubjectId, widget.TermIndex);
  }

  List<AdminLesson> reorderedLessons;
  void ReorderLessons(
    context,
  ) async {
    String ids = '';
    reorderedLessons.map((e) {
      ids += '${e.id},';
    }).toList();
    ids = ids.substring(0, ids.length - 1);
    print(ids);
    await Provider.of<CurriculumProvider>(context, listen: false)
        .OrderLessons(context, ids);
    Provider.of<CurriculumProvider>(context, listen: false)
        .getData(widget.YearSubjectId, widget.TermIndex);
  }

  bool showReorderTip = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: InkWell(
            onTap: () {
              var lessonsWithNoParent =
                  Provider.of<CurriculumProvider>(context, listen: false)
                      .lessonsWithNoParent;
              navigateTo(
                  context,
                  CurriculumLessonDetailsScreen(
                    dir: widget.dir,
                    yearSubjectId: widget.YearSubjectId,
                    termIndex: widget.TermIndex,
                    lessonsWithNoParents: lessonsWithNoParent,
                  ));
            },
            child: Directionality(
              textDirection:
                  widget.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    border: Border(top: BorderSide(color: Colors.black26))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.green.shade200,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(widget.dir == "ltr" ? "New Lesson" : "درس جديد",
                        style: TextStyle(
                            color: Colors.green.shade200,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            )),
        appBar: appBarComponent(context,
            widget.dir == "ltr" ? "Curriculum Lessons" : "دروس المنهج"),
        body: FutureBuilder(
            future: Provider.of<CurriculumProvider>(context, listen: false)
                .getData(widget.YearSubjectId, widget.TermIndex),
            builder: ((context, snapshot) =>
                Consumer<CurriculumProvider>(builder: (ctx, model, child) {
                  return model.isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Directionality(
                          textDirection: widget.dir == "ltr"
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //curriculum info
                                    Container(
                                      alignment: widget.dir == "ltr"
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      width: double.infinity,
                                      padding: EdgeInsets.all(6),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 7),
                                      decoration: BoxDecoration(
                                          color:
                                              Colors.purple.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color:
                                                  defaultColor.withOpacity(0.4),
                                              width: 1)),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Text(
                                              '${model.CurriculumName} - ${model.YearOfStudyName} - ${model.TermName}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      Colors.purple.shade600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    model.lessons.length > 1 &&
                                            showReorderTip == true
                                        ? Container(
                                            margin: EdgeInsets.only(
                                              top: 0,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb,
                                                    color:
                                                        Colors.amber.shade700,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget.dir == "ltr"
                                                          ? "Tap, Long Hold with Drag to reorder items"
                                                          : "للترتيب: إضغط طويلا مع سحب العنصر رأسيا",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .amber.shade700,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        showReorderTip = false;
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                      size: 17,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors
                                                          .amber.shade700),
                                                  color: Colors.amber
                                                      .withOpacity(0.05)),
                                            ),
                                          )
                                        : Container(),
                                    Expanded(
                                      child: Container(
                                        height: double.infinity,
                                        child: model.items.length == 0
                                            ? Center(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/empty-curriculum.jpg',
                                                        height: 175,
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        widget.dir == "ltr"
                                                            ? 'No plan has been set so far!'
                                                            : 'لم يتم وضع خطة لهذا المنهج حتى الآن!',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black38,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      if (widget.dir == "ltr")
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                      Text(
                                                        widget.dir == "ltr"
                                                            ? "To put the plan, click on 'New Lesson'"
                                                            : 'لوضع الخطة، اذهب اسفل الشاشة...',
                                                        style: TextStyle(
                                                            fontSize:
                                                                widget.dir ==
                                                                        "ltr"
                                                                    ? 18
                                                                    : 20,
                                                            color: Colors
                                                                .purple.shade700
                                                                .withOpacity(
                                                                    0.8),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ]),
                                              )
                                            : ReorderableListView.builder(
                                                itemCount: model.lessons.length,
                                                onReorder:
                                                    (oldIndex, newIndex) {
                                                  setState(() {
                                                    if (oldIndex < newIndex) {
                                                      newIndex--;
                                                    }
                                                    reorderedLessons = [
                                                      ...model.lessons
                                                    ];
                                                    final tile =
                                                        reorderedLessons
                                                            .removeAt(oldIndex);
                                                    reorderedLessons.insert(
                                                        newIndex, tile);
                                                  });
                                                  ReorderLessons(context);
                                                },
                                                itemBuilder: (context, index) {
                                                  var item =
                                                      model.lessons[index];
                                                  return Item(
                                                    key: ValueKey(item),
                                                    item: item,
                                                    widget: widget,
                                                    DeleteLesson: () =>
                                                        DeleteLesson(item.id),
                                                    lessonsWithNoParents: Provider
                                                            .of<CurriculumProvider>(
                                                                context,
                                                                listen: false)
                                                        .lessonsWithNoParent,
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ])));
                }))));
  }
}

class Item extends StatelessWidget {
  Item({
    Key key,
    @required this.item,
    @required this.widget,
    this.lessonsWithNoParents,
    @required this.DeleteLesson,
  }) : super(key: key);

  final AdminLesson item;

  final CurriculumEditScreen widget;
  List<AdminLesson> lessonsWithNoParents;
  final Function DeleteLesson;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        navigateTo(
            context,
            CurriculumLessonDetailsScreen(
              lesson: item,
              dir: widget.dir,
              termIndex: widget.TermIndex,
              yearSubjectId: widget.YearSubjectId,
              lessonsWithNoParents: lessonsWithNoParents,
            ));
      },
      child: Card(
        //----------------------------------------------Card
        elevation: item.parentLessonId != null ? 0 : 1,
        margin: EdgeInsets.all(2),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: item.active
                      ? item.parentLessonId != null
                          ? defaultColor.withOpacity(0.3)
                          : defaultColor.withOpacity(0.5)
                      : Colors.black26),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                if (item.parentLessonId != null)
                  SizedBox(
                    width: 20,
                  ),
                Expanded(
                    child: Text(item.lessonName,
                        style: TextStyle(
                            fontWeight: item.parentLessonId == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: item.active
                                ? Colors.black87
                                : Colors.black26))),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  item.blockedFromAddingSessions
                      ? Icons.lock_outline
                      : Icons.lock_open_outlined,
                  color: item.blockedFromAddingSessions
                      ? Colors.red
                      : Colors.black38,
                  size: 18,
                ),
                SizedBox(
                  width: 2,
                ),
                Directionality(
                  textDirection: widget.dir == "ltr"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: PopupMenuButton(
                      icon: Icon(Icons.more_horiz,
                          color: Colors.black54), // add this line
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 175,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          !item.blockedFromAddingSessions
                                              ? Icons.lock_outline
                                              : Icons.lock_open_outlined,
                                          color: !item.blockedFromAddingSessions
                                              ? Colors.red
                                              : Colors.black38,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          item.blockedFromAddingSessions
                                              ? widget.dir == "ltr"
                                                  ? "Remove Block"
                                                  : "رفع الحظر"
                                              : widget.dir == "ltr"
                                                  ? "Block adding content"
                                                  : "حظر إضافة محتوى",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )),
                                value: 'block'),
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 175,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          widget.dir == "rtl"
                                              ? Icons.arrow_circle_left_outlined
                                              : Icons
                                                  .arrow_circle_right_outlined,
                                          color: Colors.amber.shade700,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.dir == "ltr"
                                              ? "move to the other term"
                                              : "نقل إلى الترم الأخر",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )),
                                value: 'switchterm'),
                            new PopupMenuItem<String>(
                                child: Container(
                                    width: 175,
                                    // height: 30,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red.shade700,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.dir == "ltr"
                                              ? "Delete"
                                              : "حذف",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )),
                                value: 'delete'),
                          ],
                      onSelected: (index) async {
                        switch (index) {
                          case 'delete': //--------------------------------------remove record
                            showDialog(
                                context: context,
                                builder: (ctx) => Directionality(
                                      textDirection: widget.dir == "ltr"
                                          ? TextDirection.ltr
                                          : TextDirection.rtl,
                                      child: AlertDialog(
                                        titleTextStyle: TextStyle(
                                            color: defaultColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        title: Text(widget.dir == "ltr"
                                            ? 'Are you sure?'
                                            : "هل انت متأكد؟"),
                                        content: Text(
                                          widget.dir == "ltr"
                                              ? 'Are you sure that you want to remove this record?'
                                              : "هل تريد حذف هذا السجل؟",
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(widget.dir == "ltr"
                                                ? "No"
                                                : "لا"),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(widget.dir == "ltr"
                                                ? 'Yes'
                                                : "نعم"),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              DeleteLesson();
                                            },
                                          ),
                                        ],
                                      ),
                                    ));

                            break;
                          // case 'edit':
                          //   navigateTo(
                          //       context, CurriculumLessonDetailsScreen(item));
                          //   break;
                          case 'switchterm':
                            await Provider.of<CurriculumProvider>(context,
                                    listen: false)
                                .SwitchTermIndex(LessonId: item.id);
                            Provider.of<CurriculumProvider>(context,
                                    listen: false)
                                .getData(
                                    widget.YearSubjectId, widget.TermIndex);
                            break;
                          case 'block':
                            Provider.of<CurriculumProvider>(context,
                                    listen: false)
                                .SwitchLessonBlock(
                                    context: context, LessonId: item.id);
                            // Provider.of<CurriculumProvider>(context,
                            //         listen: false)
                            //     .getData(context, widget.YearSubjectId,
                            //         widget.TermIndex);
                            break;

                          //-------------------------------------Edit Note
                        }
                      }),
                ),
              ]),
              SizedBox(
                height: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
