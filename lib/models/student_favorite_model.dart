class StudentFavorite {
  int sessionHeaderId;
  String lessonName;
  String lessonDescription;
  int teacherId;
  String teacherName;
  String teacherPhoto;
  String urlSource;
  int videos;
  int quizes;
  int videosProgress;
  String subjectName;
  String dir;
  StudentFavorite({
    this.sessionHeaderId,
    this.lessonName,
    this.lessonDescription,
    this.teacherId,
    this.teacherName,
    this.teacherPhoto,
    this.urlSource,
    this.videos,
    this.quizes,
    this.videosProgress,
    this.subjectName,
    this.dir,
  });

  StudentFavorite.fromJson(Map<String, dynamic> json) {
    sessionHeaderId = json['sessionHeaderId'];
    lessonName = json['lessonName'];
    lessonDescription = json['lessonDescription'];
    teacherId = json['teacherId'];
    teacherName = json['teacherName'];
    teacherPhoto = json['teacherPhoto'];
    urlSource = json['urlSource'];
    videos = json['videos'];
    quizes = json['quizes'];
    videosProgress = json['videosProgress'];
    subjectName = json['subjectName'];
    dir = json['dir'];
  }
}
