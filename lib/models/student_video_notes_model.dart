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
  dynamic aspectRatio;
  String urlSource;
  int sessionHeaderId;
  String lessonName;
  String dir;
  String note;
  String teacherName;
  String videoName;
  String title;
  String coverUrl;
  String coverUrlSource;
  int goToSecond;

  StudentVideoNote.fromJson(Map<String, dynamic> json) {
    videoId = json['videoId'];
    videoUrl = json['videoUrl'];
    urlSource = json['urlSource'];
    aspectRatio = json['width'] / json['height'];
    sessionHeaderId = json['sessionHeaderId'];
    lessonName = json['lessonName'];
    dir = json['dir'];
    note = json['note'];
    teacherName = json['teacherName'];
    videoName = json['videoName'];
    title = json['title'];

    coverUrlSource = json['coverUrlSource'];
    coverUrl = json['coverUrl'];
    title = json['title'];
    goToSecond = json['goToSecond'];
  }
}
