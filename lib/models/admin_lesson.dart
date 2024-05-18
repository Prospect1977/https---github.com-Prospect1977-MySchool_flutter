class AdminLesson {
  int id;

  String lessonName;
  String lessonDescription;

  bool blockedFromAddingSessions;
  int parentLessonId;

  bool active;

  AdminLesson.fromJson(Map<String, dynamic> js) {
    id = js["id"];

    lessonName = js["lessonName"];
    lessonDescription = js["lessonDescription"];

    blockedFromAddingSessions = js["blockedFromAddingSessions"];
    parentLessonId = js["parentLessonId"];

    active = js["active"];
  }
}

class AdminLessons {
  List<AdminLesson> items = [];
  AdminLessons.fromJson(List<Object> js) {
    js.forEach((item) {
      items.add(AdminLesson.fromJson(item));
    });
  }
}
