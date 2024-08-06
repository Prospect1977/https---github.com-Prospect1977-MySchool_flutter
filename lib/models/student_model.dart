class StudentModel {
  int studentId;
  String fullName;
  String gender;
  int schoolTypeId;
  int yearOfStudyId;
  bool isStudentHasParent;

  StudentModel(
      {this.studentId,
      this.fullName,
      this.gender,
      this.schoolTypeId,
      this.yearOfStudyId,
      this.isStudentHasParent});

  StudentModel.fromJson(Map<String, dynamic> json) {
    studentId = json['studentId'];
    fullName = json['fullName'];
    gender = json['gender'];
    schoolTypeId = json['schoolTypeId'];
    yearOfStudyId = json['yearOfStudyId'];
    isStudentHasParent = json['isStudentHasParent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentId'] = this.studentId;
    data['fullName'] = this.fullName;
    data['gender'] = this.gender;
    data['schoolTypeId'] = this.schoolTypeId;
    data['yearOfStudyId'] = this.yearOfStudyId;
    data['isStudentHasParent'] = this.isStudentHasParent;
    return data;
  }
}
