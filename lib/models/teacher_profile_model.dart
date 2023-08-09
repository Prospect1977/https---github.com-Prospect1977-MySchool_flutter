class TeacherProfileModel {
  int id;
  String fullName;
  String userId;
  String photo;
  String urlSource;
  dynamic rate;
  String biography;
  String biographyDir;
  int views;
  String nationalId;

  TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userId = json['userId'];
    photo = json['photo'];
    urlSource = json['urlSource'];
    rate = json['rate'];
    biography = json['biography'];
    biographyDir = json['biographyDir'];
    views = json["views"];
    nationalId = json["nationalId"];
  }
}
