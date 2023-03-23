class RecentTeacherSession {
  int termIndex;
  int lessonId;
  String lessonName;
  int sessionHeaderId;
  String subjectName;
  String dir;
  int yearSubjectId;
  String yearOfStudyAra;
  String yearOfStudyEng;
  int videos;
  int quizzes;
  int documents;
  RecentTeacherSession.fromJson(Map<String, dynamic> json) {
    termIndex = json["termIndex"];
    lessonId = json["lessonId"];
    lessonName = json['lessonName'];
    sessionHeaderId = json['sessionHeaderId'];
    subjectName = json['subjectName'];
    dir = json['dir'];
    yearSubjectId = json['yearSubjectId'];
    yearOfStudyAra = json['yearOfStudyAra'];
    yearOfStudyEng = json['yearOfStudyEng'];
    videos = json['videos'];
    quizzes = json['quizzes'];
    documents = json['documents'];
  }
}

class RecentTeacherSessions {
  List<RecentTeacherSession> Sessions = [];

  RecentTeacherSessions.fromJson(List<Object> js) {
    js.forEach((j) {
      Sessions.add(RecentTeacherSession.fromJson(j));
    });
  }
}
