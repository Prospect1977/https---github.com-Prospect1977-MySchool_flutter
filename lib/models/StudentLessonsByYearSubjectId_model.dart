class StudentLessonsByYearSubjectId {
  int id;
  DateTime dataDate;
  String lessonName;
  String dir;
  bool blockedFromAddingSessions;
  int parentLessonId;
  StudentLessonsByYearSubjectId.fromJson(Map<String, dynamic> js) {
    id = js["id"];
    dataDate = js["dataDate"] == "" ? null : DateTime.parse(js["dataDate"]);
    lessonName = js["lessonName"];
    dir = js["dir"];
    blockedFromAddingSessions = js["blockedFromAddingSessions"];
    parentLessonId = js["parentLessonId"];
  }
}

class StudentLessonsByYearSubjectId_collection {
  List<StudentLessonsByYearSubjectId> items = [];
  StudentLessonsByYearSubjectId_collection.fromJson(List<Object> js) {
    js.forEach((item) {
      items.add(StudentLessonsByYearSubjectId.fromJson(item));
    });
  }
}
