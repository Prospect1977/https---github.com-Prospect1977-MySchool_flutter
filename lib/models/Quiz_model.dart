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
  List<Answer> answers;

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionType = json['questionType'];
    title = json['title'];
    questionImageUrl = json['questionImageUrl'];
    if (json['answers'] != null) {
      answers = <Answer>[];
      json['answers'].forEach((v) {
        answers.add(new Answer.fromJson(v));
      });
    }
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
}
