class QuizAnalysisLesson {
  String subjectName;
  String yearOfStudy;
  int termIndex;
  int sessionHeaderId;
  String name;
  String dir;
  int quizzesCount;

  QuizAnalysisLesson(
      {this.subjectName,
      this.yearOfStudy,
      this.termIndex,
      this.sessionHeaderId,
      this.name,
      this.dir,
      this.quizzesCount});

  QuizAnalysisLesson.fromJson(Map<String, dynamic> json) {
    subjectName = json['subjectName'];
    yearOfStudy = json['yearOfStudy'];
    termIndex = json['termIndex'];
    sessionHeaderId = json['sessionHeaderId'];
    name = json['name'];
    dir = json['dir'];
    quizzesCount = json['quizzesCount'];
  }
}

class QuizInSession {
  int sessionDetailId;
  int quizId;
  int examinersCount;
  int succeeded;
  int failed;
  int questionsCount;

  QuizInSession(
      {this.sessionDetailId,
      this.quizId,
      this.examinersCount,
      this.succeeded,
      this.failed,
      this.questionsCount});

  QuizInSession.fromJson(Map<String, dynamic> json) {
    sessionDetailId = json['sessionDetailId'];
    quizId = json['quizId'];
    examinersCount = json['examinersCount'];
    succeeded = json['succeeded'];
    failed = json['failed'];
    questionsCount = json['questionsCount'];
  }
}

class QuizQuestionAnalysis {
  String title;
  String type;
  String url;
  String urlSource;
  int studentsWhoSkipped;
  List<Answer> answers;

  QuizQuestionAnalysis(
      {this.title,
      this.type,
      this.url,
      this.urlSource,
      this.studentsWhoSkipped,
      this.answers});

  QuizQuestionAnalysis.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    type = json['type'];
    url = json['url'];
    urlSource = json['urlSource'];
    studentsWhoSkipped = json['studentsWhoSkipped'];
    if (json['answers'] != null) {
      answers = <Answer>[];
      json['answers'].forEach((v) {
        answers.add(new Answer.fromJson(v));
      });
    }
  }
}

class Answer {
  String title;
  bool isRightAnswer;
  int studentsWhoSelectedThisAnswer;

  Answer({this.title, this.isRightAnswer, this.studentsWhoSelectedThisAnswer});

  Answer.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    isRightAnswer = json['isRightAnswer'];
    studentsWhoSelectedThisAnswer = json['studentsWhoSelectedThisAnswer'];
  }
}

class QuizStudentDegree {
  int studentId;
  String fullName;
  dynamic degree;
  DateTime dataDate;
  String quizAccessCode;
  //int? questionsCount;

  QuizStudentDegree({
    this.studentId,
    this.fullName,
    this.degree,
    this.dataDate,
    this.quizAccessCode,
    // this.questionsCount
  });

  QuizStudentDegree.fromJson(Map<String, dynamic> json) {
    studentId = json['studentId'];
    fullName = json['fullName'];
    degree = json['degree'];
    quizAccessCode = json['quizAccessCode'];
    dataDate = DateTime.parse(json['dataDate']);
    // questionsCount = json['questionsCount'];
  }
}
