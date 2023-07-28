import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/dio_helper.dart';

class TicketScreen extends StatefulWidget {
  TicketScreen({this.StudentId, Key key}) : super(key: key);
  int StudentId;
  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  var lang = CacheHelper.getData(key: "lang");
  var roles = CacheHelper.getData(key: "roles");
  var UserId = CacheHelper.getData(key: "userId");
  var token = CacheHelper.getData(key: "token");
  String descDirection = "";

  bool isUserDataLoaded = false;
  bool isSendingData = false;
  bool isSavedSuccess = false;

  TextEditingController phoneNumberController = new TextEditingController();
  //TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  var formKey = GlobalKey<FormState>();
  void getUserData() {
    DioHelper.getData(
            url: 'Ticket/UserDataById',
            query: {"Id": UserId},
            lang: "ar",
            token: token)
        .then((value) {
      print(value.data["data"]);
      setState(() {
        isUserDataLoaded = true;
        var phone = value.data["data"]["phoneNumber"];
        phoneNumberController.text = phone == null ? "" : phone;
      });
    }).catchError((e) {
      print(e.toString());
      setState(() {
        isUserDataLoaded = true;
      });
    });
  }

  void saveTicket() {
    FocusScope.of(context).unfocus();
    setState(() {
      isSendingData = true;
    });
    print(widget.StudentId);
    //SaveTicket(string UserId,string PhoneNumber,int StudentId,string Title,
    //string Description,string DescriptionDir,DateTime PublishDate, string? FileUrl)
    DioHelper.postData(
            url: 'Ticket/SaveTicket',
            query: {
              "UserId": UserId,
              'PhoneNumber': phoneNumberController.text,
              'StudentId': widget.StudentId,
              //'Title': titleController.text,
              'Description': descriptionController.text,
              'DescriptionDir': descDirection,
              'PublishDate': DateTime.now()
            },
            lang: "ar",
            token: token)
        .then((value) {
      if (value.data["status"] == true) {
        setState(() {
          isSavedSuccess = true;
          isSendingData = false;
        });
      } else {
        showToast(
            text: lang == "en"
                ? "An unkown error occured!"
                : "حدث خطأ غير معروف!",
            state: ToastStates.ERROR);
      }

      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    }).catchError((e) {
      print(e.toString());
      setState(() {
        isSendingData = false;
        showToast(
            text: lang == "en"
                ? "An unkown error occured!"
                : "حدث خطأ غير معروف!",
            state: ToastStates.ERROR);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    setState(() {
      descDirection = lang == "en" ? "ltr" : "rtl";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: appBarComponent(
            context, lang == "en" ? "Contact Us" : "تواصل معنا"),
        body: !isUserDataLoaded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Center(
                  child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            defaultFormField(
                              controller: phoneNumberController,
                              type: TextInputType.number,
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return lang == "en"
                                      ? 'please enter your Phone Number'
                                      : 'من فضلك ادخل رقم الهاتف';
                                }
                              },
                              label:
                                  lang == "en" ? 'Phone Number' : 'رقم الهاتف',
                              prefix: Icons.phone,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            // Directionality(
                            //   textDirection: descDirection == "ltr"
                            //       ? TextDirection.ltr
                            //       : TextDirection.rtl,
                            //   child: defaultFormField(
                            //     controller: titleController,
                            //     type: TextInputType.name,
                            //     validate: (String value) {
                            //       if (value.isEmpty) {
                            //         return lang == "en"
                            //             ? 'please enter a title'
                            //             : 'من فضلك ادخل العنوان';
                            //       }
                            //     },
                            //     label: lang == "en" ? 'Title' : 'العنوان',
                            //     prefix: Icons.title_rounded,
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15,
                            // ),
                            Stack(children: [
                              Directionality(
                                textDirection: descDirection == "ltr"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: defaultFormField(
                                  onChange: (value) {},
                                  maximumLines: 6,
                                  controller: descriptionController,
                                  type: TextInputType.multiline,
                                  label: lang == "en" ? 'Message' : "الرسالة",
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return lang == "en"
                                          ? 'please write the message'
                                          : 'من فضلك اكتب الرسالة ';
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                top: 2,
                                left: descDirection == "rtl" ? 2 : null,
                                right: descDirection == "ltr" ? 2 : null,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          descDirection = "rtl";
                                        });
                                      },
                                      child: Container(
                                          width: 30,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              color: descDirection == "rtl"
                                                  ? Colors.purple
                                                  : Colors.white),
                                          child: Center(
                                            child: Text(
                                              "Ar",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: descDirection == "rtl"
                                                      ? Colors.white
                                                      : Colors.black54),
                                            ),
                                          )),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          descDirection = "ltr";
                                        });
                                      },
                                      child: Container(
                                          width: 30,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              color: descDirection == "ltr"
                                                  ? Colors.purple
                                                  : Colors.white),
                                          child: Center(
                                            child: Text(
                                              "En",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: descDirection == "ltr"
                                                      ? Colors.white
                                                      : Colors.black45),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 15,
                            ),
                            isSendingData
                                ? CircularProgressIndicator()
                                : !isSavedSuccess
                                    ? defaultButton(
                                        function: () {
                                          if (formKey.currentState.validate()) {
                                            saveTicket();
                                          }
                                        },
                                        text: lang == "en" ? 'Submit' : 'إرسال',
                                        isUpperCase: false,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.1),
                                            border: Border.all(
                                                color: Colors.green
                                                    .withOpacity(0.4)),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Text(
                                          lang == "en"
                                              ? "We recieved your message and we will reply shortly"
                                              : "لقد تلقينا رسالتك وسنرد عليك في اسرع وقت",
                                          style: TextStyle(
                                              color: Colors.green.shade900,
                                              fontSize: 16),
                                        ),
                                      )
                          ],
                        ),
                      )),
                )),
      ),
    );
  }
}
