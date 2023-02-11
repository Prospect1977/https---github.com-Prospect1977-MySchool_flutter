import 'package:flutter/cupertino.dart';

class StudentAnswer {
  int QuestionId;
  int AnswerId;
  String AnswerText;
  bool IsAnswerRight;
  StudentAnswer(
      {@required this.QuestionId,
      this.AnswerId,
      this.AnswerText,
      this.IsAnswerRight});
  StudentAnswer.fromJson(Map<String, dynamic> js) {
    this.QuestionId = js["questionId"];
    this.AnswerId = js["answerId"];
    this.AnswerText = js["answerText"];
    this.IsAnswerRight = js["isAnswerRight"];
  }
}

class StudentAnswers {
  List<StudentAnswer> StuAnswers;
  StudentAnswers(this.StuAnswers);
  StudentAnswers.fromJson(List<Object> js) {
    StuAnswers = [];
    js.forEach((element) {
      StuAnswers.add(StudentAnswer.fromJson(element));
    });
  }
  List<Object> toJson() {
    var dataList = [];
    StuAnswers.map((a) {
      Map<String, dynamic> data = new Map<String, dynamic>();
      data['QuestionId'] = a.QuestionId;
      data['AnswerId'] = a.AnswerId;
      data['AnswerText'] = a.AnswerText;
      data['IsAnswerRight'] = a.IsAnswerRight;
      dataList.add(data);
    }).toList();

    return dataList;
  }
}
