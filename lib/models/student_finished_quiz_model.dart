class StudentFinishedQuiz {
  int quizId;
  String lessonName;
  int degree;
  DateTime dataDate;
  bool isQuizLimited;
  String limitedQuizCode;

  StudentFinishedQuiz(
      {this.quizId,
      this.lessonName,
      this.degree,
      this.dataDate,
      this.isQuizLimited,
      this.limitedQuizCode});

  StudentFinishedQuiz.fromJson(Map<String, dynamic> json) {
    quizId = json['quizId'];
    lessonName = json['lessonName'];
    degree = json['degree'];
    isQuizLimited = json['isQuizLimited'];
    limitedQuizCode = json['limitedQuizCode'];
    dataDate = DateTime.parse(json['dataDate']);
  }
}
