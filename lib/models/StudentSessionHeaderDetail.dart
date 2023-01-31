class StudentSessionHeaderDetail {
  String type;
  int id;
  bool isDisabled;
  int documentId;
  int videoId;
  int quizId;
  String title;
  String videoUrl;
  String documentUrl;
  dynamic videoProgress;
  dynamic quizProgress;
  dynamic quizDegree;
  StudentSessionHeaderDetail.fromJson(Map<String, dynamic> js) {
    type = js["type"];
    id = js["id"];
    isDisabled = js["isDisabled"];
    documentId = js["documentId"];
    videoId = js["videoId"];
    quizId = js["quizId"];
    title = js["title"];
    videoUrl = js["videoUrl"];
    documentUrl = js["documentUrl"];
    videoProgress = js["videoProgress"];
    quizProgress = js["quizProgress"];
    quizDegree = js["quizDegree"];
  }
}

class StudentSessionHeaderDetailCollection {
  List<StudentSessionHeaderDetail> items = [];
  StudentSessionHeaderDetailCollection.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(StudentSessionHeaderDetail.fromJson(element));
    });
  }
}
