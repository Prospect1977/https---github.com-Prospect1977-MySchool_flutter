import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/models/teacher_session.dart';
import 'package:my_school/screens/teacher_session_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/widgets/teacher_session_navigation_bar.dart';

class TeacherSessionSettingsScreen extends StatefulWidget {
  TeacherSessionSettingsScreen(
      {@required this.TeacherId,
      @required this.LessonId,
      @required this.LessonName,
      @required this.YearSubjectId,
      @required this.TermIndex,
      @required this.dir,
      @required Key key})
      : super(key: key);
  int TeacherId;
  int YearSubjectId;
  int TermIndex;
  int LessonId;
  String LessonName;
  String dir;

  @override
  State<TeacherSessionSettingsScreen> createState() =>
      _TeacherSessionSettingsScreenState();
}

class _TeacherSessionSettingsScreenState
    extends State<TeacherSessionSettingsScreen> {
  bool isFree;
  bool active;

  bool isDirty = false;
  TeacherSession sessionData = null;
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  TextEditingController priceController = new TextEditingController();
  void getData() async {
    DioHelper.getData(
            url: "TeacherSession",
            query: {
              "TeacherId": widget.TeacherId,
              "LessonId": widget.LessonId,
              "DataDate": DateTime.now()
            },
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        sessionData = TeacherSession.fromJson(value.data['data']);
        isFree = sessionData.isFree;
        active = sessionData.active;
        priceController.text =
            sessionData.price == null ? "" : sessionData.price.toString();
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void SaveChanges() async {
    if (isFree == false && priceController.text == "") {
      showToast(
          text: lang == "en" ? "Price is required!" : "مطلوب تحديد السعر!",
          state: ToastStates.ERROR);
      navigateTo(
          context,
          TeacherSessionScreen(
              TeacherId: widget.TeacherId,
              YearSubjectId: widget.YearSubjectId,
              TermIndex: widget.TermIndex,
              LessonId: widget.LessonId,
              LessonName: widget.LessonName,
              dir: widget.dir));
      return;
    }
    DioHelper.postData(
            url: "TeacherSession/SaveSessionHeaderData",
            query: {
              "TeacherId": widget.TeacherId,
              "LessonId": widget.LessonId,
              "Active": active,
              "IsFree": isFree,
              "Price": isFree ? 0.0 : priceController.text
            },
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      showToast(
          text: lang == "en"
              ? "Changes saved successfuly!"
              : "تم حفظ التعديلات بنجاح!",
          state: ToastStates.SUCCESS);
      navigateTo(
          context,
          TeacherSessionScreen(
              TeacherId: widget.TeacherId,
              YearSubjectId: widget.YearSubjectId,
              TermIndex: widget.TermIndex,
              LessonId: widget.LessonId,
              LessonName: widget.LessonName,
              dir: widget.dir));
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context, widget.LessonName),
      body: sessionData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Directionality(
              textDirection:
                  lang == "en" ? TextDirection.ltr : TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        active = false;
                        isDirty = true;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          active == false
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off,
                          color: active == false
                              ? Colors.red.shade700
                              : Colors.black38,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            lang == "en"
                                ? "Content is not ready for students to view"
                                : "المحتوى غير جاهز للعرض على الطلبة",
                            style: TextStyle(
                                color: active == false
                                    ? Colors.red.shade700
                                    : Colors.black54,
                                fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        active = true;
                        isDirty = true;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          active
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off,
                          color:
                              active ? Colors.green.shade700 : Colors.black38,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            lang == "en"
                                ? "Content is ready and available for students"
                                : "المحتوى جاهز ومتاح للطلبة",
                            style: TextStyle(
                                color: active
                                    ? Colors.green.shade700
                                    : Colors.black54,
                                fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          isFree = !isFree;
                          isDirty = true;
                        });
                      },
                      child: Row(
                        children: [
                          isFree
                              ? Icon(
                                  Icons.check_box,
                                  color: Colors.black54,
                                )
                              : Icon(
                                  Icons.check_box_outline_blank_rounded,
                                  color: Colors.black54,
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            lang == "en" ? "Free Content" : "المحتوى مجاني",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 20),
                          )
                        ],
                      )),
                  isFree == false
                      ? SizedBox(
                          height: 10,
                        )
                      : Container(),
                  isFree == false
                      ? defaultFormField(
                          controller: priceController,
                          onChange: (_) {
                            setState(() {
                              isDirty = true;
                            });
                          },
                          type: TextInputType.number,
                          label: lang == "en" ? "Price (EGP)" : "السعر (ج.م)")
                      : Container(),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  defaultButton(
                    function: () {
                      SaveChanges();
                    },
                    background:
                        isDirty ? Colors.green.shade700 : Colors.black26,
                    text: lang == "en" ? "Save Changes" : "حفظ التعديلات",
                  )
                ]),
              ),
            ),
      bottomNavigationBar: TeacherSessionNavigationBar(
          LessonId: widget.LessonId,
          LessonName: widget.LessonName,
          TeacherId: widget.TeacherId,
          TermIndex: widget.TermIndex,
          YearSubjectId: widget.YearSubjectId,
          dir: widget.dir,
          PageIndex: 1),
    );
  }
}
