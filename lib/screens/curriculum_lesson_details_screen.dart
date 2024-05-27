import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/admin_lesson.dart';
import 'package:my_school/providers/CurriculumProvider.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:provider/provider.dart';

class CurriculumLessonDetailsScreen extends StatefulWidget {
  CurriculumLessonDetailsScreen(
      {@required this.yearSubjectId,
      @required this.termIndex,
      @required this.dir,
      this.lesson,
      this.lessonsWithNoParents,
      Key key})
      : super(key: key);
  String dir;
  List<AdminLesson> lessonsWithNoParents;
  AdminLesson lesson;
  int termIndex;
  int yearSubjectId;
  @override
  State<CurriculumLessonDetailsScreen> createState() =>
      _CurriculumLessonDetailsScreenState();
}

class _CurriculumLessonDetailsScreenState
    extends State<CurriculumLessonDetailsScreen> {
  var formKey = GlobalKey<FormState>();
  //  var lang=CacheHelper.getData(key: 'lang');
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isActive = true;
  bool isBlockedFromAddingContent = false;
  List<DropdownMenuItem> ParentLessons = [];
  int currentParentLesson = 0;
  bool isSaving = false;
  void generateParentLessons() {
    setState(() {
      if (widget.lessonsWithNoParents != null) {
        ParentLessons = widget.lessonsWithNoParents
            .map((s) => DropdownMenuItem(
                  child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.white))),
                    alignment: widget.dir == "ltr"
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Text(s.lessonName),
                  ),
                  value: s.id,
                ))
            .toList();
      } else {
        ParentLessons = [];
      }
    });
  }

  void SaveData() async {
    setState(() {
      isSaving = false;
    });
    if (widget.lesson == null) {
      //  int TermIndex,
      //   int YearSubjectId,
      //   String Name,
      //   String Description,
      //   bool Active,
      //   int ParentLessonId,
      //   bool BlockedFromAddingSessions
      await Provider.of<CurriculumProvider>(context, listen: false)
          .CreateLesson(
        TermIndex: widget.termIndex,
        YearSubjectId: widget.yearSubjectId,
        Name: titleController.text,
        Description: descriptionController.text,
        Active: isActive,
        ParentLessonId: currentParentLesson == 0 ? null : currentParentLesson,
        BlockedFromAddingSessions: isBlockedFromAddingContent,
      );
      await Provider.of<CurriculumProvider>(context, listen: false)
          .getData(widget.yearSubjectId, widget.termIndex);
      Navigator.of(context).pop();
    } else {
      await Provider.of<CurriculumProvider>(context, listen: false).EditLessson(
        Id: widget.lesson.id,
        TermIndex: widget.termIndex,
        YearSubjectId: widget.yearSubjectId,
        Name: titleController.text,
        Description: descriptionController.text,
        Active: isActive,
        ParentLessonId: currentParentLesson == 0 ? null : currentParentLesson,
        BlockedFromAddingSessions: isBlockedFromAddingContent,
      );
      await Provider.of<CurriculumProvider>(context, listen: false)
          .getData(widget.yearSubjectId, widget.termIndex);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.lessonsWithNoParents);
    generateParentLessons();
    var defaultParentLesson =
        CacheHelper.getData(key: 'defaultParentLesson') != null
            ? CacheHelper.getData(key: 'defaultParentLesson')
            : 0;
    if (widget.lesson == null) {
      if (widget.lessonsWithNoParents
              .where((element) => element.id == defaultParentLesson)
              .length ==
          1) {
        currentParentLesson = defaultParentLesson;
      } else {
        currentParentLesson = 0;
      }
    }

    if (widget.lesson != null) {
      if (widget.lesson.parentLessonId != null) {
        currentParentLesson = widget.lesson.parentLessonId;
      }
      titleController.text = widget.lesson.lessonName;
      descriptionController.text = widget.lesson.lessonDescription;
      currentParentLesson = widget.lesson.parentLessonId == null
          ? 0
          : widget.lesson.parentLessonId;
      isActive = widget.lesson.active;
      isBlockedFromAddingContent = widget.lesson.blockedFromAddingSessions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context, widget.dir == "ltr" ? "Details" : "التفاصيل"),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Directionality(
          textDirection:
              widget.dir == "ltr" ? TextDirection.ltr : TextDirection.rtl,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(children: [
                defaultFormField(
                  controller: titleController,
                  type: TextInputType.name,
                  validate: (value) {
                    if (value.isEmpty) {
                      return widget.dir == "ltr"
                          ? "Please enter the  title!"
                          : "من فضلك ادخل العنوان !";
                    }
                    return null;
                  },
                  label: widget.dir == "rtl" ? "العنوان" : "Title",
                ),
                if (widget.lessonsWithNoParents.length > 0)
                  const SizedBox(
                    height: 15.0,
                  ),
                widget.lessonsWithNoParents.length == 0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black38),
                        ),
                        child: DropdownButton(
                          //key: ValueKey(1),
                          value: currentParentLesson,
                          items: [
                            DropdownMenuItem(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white))),
                                alignment: widget.dir == "ltr"
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Text(
                                  widget.dir == "ltr"
                                      ? "Subtitle of..."
                                      : "يندرج تحت...",
                                ),
                              ),
                              value: 0,
                            ),
                            if (ParentLessons.length > 0) ...ParentLessons,
                          ],

                          onChanged: (value) {
                            setState(() {
                              currentParentLesson = value;
                              CacheHelper.saveData(
                                  key: 'defaultParentLesson', value: value);
                            });
                          },
                          icon: Padding(
                              //Icon at tail, arrow bottom is default icon
                              padding: EdgeInsets.all(0),
                              child: Icon(Icons.keyboard_arrow_down)),
                          iconEnabledColor: Colors.black54, //Icon color
                          style: TextStyle(
                              //te
                              color: Colors.black87, //Font color
                              fontSize: 16 //font size on dropdown button
                              ),
                          underline: Container(),

                          dropdownColor:
                              Colors.white, //dropdown background color
                          //remove underline
                          isExpanded: true, //make true to make width 100%
                        )),
                const SizedBox(
                  height: 15.0,
                ),
                defaultFormField(
                    controller: descriptionController,
                    type: TextInputType.multiline,
                    maximumLines: 2,
                    label: widget.dir == "ltr" ? "Notes" : "ملاحظات"),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Switch(
                      value:
                          isActive, // Boolean value indicating the current state of the switch
                      onChanged: (bool value) {
                        // Callback function called when the switch is toggled
                        setState(() {
                          isActive =
                              value; // Update the state based on the new value
                        });
                      },
                      activeColor:
                          Colors.green.shade600, // Color when the switch is ON
                    ),
                    Text(
                      widget.dir == "ltr"
                          ? "Visible for teachers"
                          : "مرئي للمعلمين",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Switch(
                      value:
                          isBlockedFromAddingContent, // Boolean value indicating the current state of the switch
                      onChanged: (bool value) {
                        // Callback function called when the switch is toggled
                        setState(() {
                          isBlockedFromAddingContent =
                              value; // Update the state based on the new value
                        });
                      },
                      activeColor:
                          Colors.red.shade600, // Color when the switch is ON
                    ),
                    Text(
                      widget.dir == "ltr"
                          ? "Blocked from adding content"
                          : "حظر إضافة محتوى",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                isSaving
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : defaultButton(
                        function: () {
                          if (formKey.currentState.validate()) {
                            SaveData();
                          }
                        },
                        borderRadius: 5,
                        background: widget.lesson != null
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                        text: widget.lesson != null
                            ? widget.dir == "ltr"
                                ? "Save"
                                : "حفظ"
                            : widget.dir == "ltr"
                                ? "Add"
                                : "إضافة",
                        isUpperCase: false,
                      ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
