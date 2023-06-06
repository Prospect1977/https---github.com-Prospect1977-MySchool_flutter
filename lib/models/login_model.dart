class LoginModel {
  bool status;
  String message;
  UserData data;

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }
}

class UserData {
  String userId;
  String fullName;
  String roles;

  String token;
  bool studentHasParent;
  int teacherId;
  String phoneNumber;
  String email;
  // named constructor
  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    fullName = json['fullName'];
    roles = json['roles'];

    token = json['token'];
    studentHasParent = json['studentHasParent'];
    teacherId = json['teacherId'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
  }
}
