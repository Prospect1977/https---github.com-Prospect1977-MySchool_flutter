class StudentLessonSession {
  int sessionId;
  int teacherId;
  String teacherName;
  String teacherPhoto;
  String urlSource;
  dynamic videosProgress;
  dynamic quizesProgress;
  bool isFree;
  dynamic price;
  int watches;
  int videos;
  int quizes;
  dynamic rate;
  bool isPurchased;
  StudentLessonSession.fromJson(Map<String, dynamic> js) {
    sessionId = js["sessionId"];
    teacherId = js["teacherId"];
    teacherName = js["teacherName"];
    teacherPhoto = js["teacherPhoto"];
    urlSource = js["urlSource"];
    videosProgress = js["videosProgress"];
    quizesProgress = js["quizesProgress"];
    isFree = js["isFree"];
    price = js["price"];
    watches = js["watches"];
    quizes = js["quizes"];
    videos = js["videos"];
    rate = js["rate"];
    isPurchased = js["isPurchased"];
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
