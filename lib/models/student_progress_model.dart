class StudentProgressRecord {
  int yearSubjectId;
  String subjectName;
  String dir;
  int watchedVideosCount;
  dynamic watchedDuration;
  String watchedDurationFormatted;
  int quizzesDone;
  dynamic averageQuizzesDegree;

  StudentProgressRecord.fromJson(Map<String, dynamic> json) {
    yearSubjectId = json['yearSubjectId'];
    subjectName = json['subjectName'];
    dir = json['dir'];
    watchedVideosCount = json['watchedVideosCount'];
    watchedDuration = json['watchedDuration'];
    watchedDurationFormatted = json['watchedDurationFormatted'];
    quizzesDone = json['quizzesDone'];
    averageQuizzesDegree = json['averageQuizzesDegree'];
  }
}

class StudentProgressModel {
  List<StudentProgressRecord> items = [];
  StudentProgressModel.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(StudentProgressRecord.fromJson(element));
    });
  }
}
