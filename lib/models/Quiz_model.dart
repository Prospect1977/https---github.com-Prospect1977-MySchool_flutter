class QuizModel {
  List<Question> Questions = [];
  QuizModel.fromJson(List<Object> js) {
    js.forEach((element) {
      Questions.add(Question.fromJson(element));
    });
  }
}

class Question {
  int id;
  String questionType;
  String title;
  String questionImageUrl;
  String urlSource;

  List<Answer> answers;

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionType = json['questionType'];
    title = json['title'];
    questionImageUrl = json['questionImageUrl'];
    urlSource = json['urlSource'];
    if (json['answers'] != null) {
      answers = <Answer>[];
      json['answers'].forEach((v) {
        answers.add(new Answer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['questionType'] = this.questionType;
    data['questionImageUrl'] = this.questionImageUrl;
    data['urlSource'] = this.urlSource;
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Answer {
  int id;
  int questionId;
  String title;
  int sortIndex;
  String answerDescription;
  String answerImageUrl;
  bool isRightAnswer;
  bool flgDelete;

  Answer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionId = json['questionId'];
    title = json['title'];
    sortIndex = json['sortIndex'];
    answerDescription = json['answerDescription'];
    answerImageUrl = json['answerImageUrl'];
    isRightAnswer = json['isRightAnswer'];
    flgDelete = json['flgDelete'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['questionId'] = this.questionId;
    data['title'] = this.title;
    data['sortIndex'] = this.sortIndex;
    data['answerDescription'] = this.answerDescription;
    data['answerImageUrl'] = this.answerImageUrl;
    data['isRightAnswer'] = this.isRightAnswer;
    return data;
  }
}
