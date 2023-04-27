class StudentVideoNotesModel {
  List<StudentVideoNote> Notes;

  StudentVideoNotesModel.fromJson(List<Object> json) {
    Notes = <StudentVideoNote>[];
    json.forEach((v) {
      Notes.add(new StudentVideoNote.fromJson(v));
    });
  }
}

class StudentVideoNote {
  int videoId;
  String videoUrl;
  String urlSource;
  int sessionHeaderId;
  String lessonName;
  String dir;
  String note;
  String teacherName;
  String videoName;
  int goToSecond;

  StudentVideoNote.fromJson(Map<String, dynamic> json) {
    videoId = json['videoId'];
    videoUrl = json['videoUrl'];
    urlSource = json['urlSource'];
    sessionHeaderId = json['sessionHeaderId'];
    lessonName = json['lessonName'];
    dir = json['dir'];
    note = json['note'];
    teacherName = json['teacherName'];
    videoName = json['videoName'];
    goToSecond = json['goToSecond'];
  }
}
