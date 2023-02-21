class TeacherViewsPerLessonModel {
  int totalVideosWatches;
  int totalVideosDurations;
  String totalVideosDurationsFormatted;
  dynamic averageWatchDuration;
  String averageWatchDurationFormatted;
  int totalQuizzes;
  dynamic averageQuizzes;
  List<SubjectReport> subjectReports;

  TeacherViewsPerLessonModel.fromJson(Map<String, dynamic> json) {
    totalVideosWatches = json['totalVideosWatches'];
    totalVideosDurations = json['totalVideosDurations'];
    totalVideosDurationsFormatted = json['totalVideosDurationsFormatted'];
    averageWatchDuration = json['averageWatchDuration'];
    averageWatchDurationFormatted = json['averageWatchDurationFormatted'];
    totalQuizzes = json['totalQuizzes'];
    averageQuizzes = json['averageQuizzes'];
    if (json['subjectReports'] != null) {
      subjectReports = <SubjectReport>[];
      json['subjectReports'].forEach((v) {
        subjectReports.add(new SubjectReport.fromJson(v));
      });
    }
  }
}

class SubjectReport {
  String yearOfStudy;
  String subjectName;
  String lessonName;
  String dir;
  int videoWatched;
  int totalVideoDuration;
  String totalVideoDurationFormatted;
  dynamic averageWatchDuration;
  String averageWatchDurationFormatted;
  int totalQuizzes;
  dynamic averageQuizzes;
  SubjectReport.fromJson(Map<String, dynamic> json) {
    yearOfStudy = json['yearOfStudy'];
    subjectName = json['subjectName'];
    lessonName = json['lessonName'];
    dir = json['dir'];
    videoWatched = json['videoWatched'];
    totalVideoDuration = json['totalVideoDuration'];
    totalVideoDurationFormatted = json['totalVideoDurationFormatted'];
    averageWatchDuration = json['averageWatchDuration'];
    averageWatchDurationFormatted = json['averageWatchDurationFormatted'];
    totalQuizzes = json['totalQuizzes'];
    averageQuizzes = json['averageQuizzes'];
  }
}
