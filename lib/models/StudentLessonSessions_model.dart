class StudentLessonSession {
  int sessionId;
  int teacherId;
  String teacherName;
  String teacherPhoto;
  dynamic videosProgress;
  dynamic quizesProgress;
  bool isFree;
  dynamic price;
  int watches;
  StudentLessonSession.fromJson(Map<String, dynamic> js) {
    sessionId = js["sessionId"];
    teacherId = js["teacherId"];
    teacherName = js["teacherName"];
    teacherPhoto = js["teacherPhoto"];
    videosProgress = js["videosProgress"];
    quizesProgress = js["quizesProgress"];
    isFree = js["isFree"];
    price = js["price"];
    watches = js["watches"];
  }
}

class StudentLessonSessions {
  List<StudentLessonSession> items = [];
  StudentLessonSessions.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(StudentLessonSession.fromJson(element));
    });
  }
}
