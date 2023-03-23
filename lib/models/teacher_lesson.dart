class TeacherLesson {
  int id;
  int videos;
  int quizzes;
  int documents;
  String dataDate;
  String lessonName;
  String lessonDescription;
  bool blockedFromAddingSessions;
  int parentLessonId;

  TeacherLesson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videos = json['videos'];
    quizzes = json['quizzes'];
    documents = json['documents'];
    dataDate = json['dataDate'];
    lessonName = json['lessonName'];
    lessonDescription = json['lessonDescription'];
    blockedFromAddingSessions = json['blockedFromAddingSessions'];
    parentLessonId = json['parentLessonId'];
  }
}

class TeacherLessons {
  List<TeacherLesson> Lessons = [];

  TeacherLessons.fromJson(List<Object> js) {
    js.forEach((j) {
      Lessons.add(TeacherLesson.fromJson(j));
    });
  }
}
