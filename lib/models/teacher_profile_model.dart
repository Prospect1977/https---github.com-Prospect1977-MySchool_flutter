class TeacherProfileModel {
  int id;
  String fullName;
  String userId;
  String photo;
  String urlSource;
  dynamic rate;
  String biography;
  String biographyDir;

  TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userId = json['userId'];
    photo = json['photo'];
    urlSource = json['urlSource'];
    rate = json['rate'];
    biography = json['biography'];
    biographyDir = json['biographyDir'];
  }
}
