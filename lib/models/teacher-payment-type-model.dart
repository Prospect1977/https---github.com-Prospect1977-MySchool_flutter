class TeacherPaymentTransferType {
  int id;
  String nameAra;
  String nameEng;

  TeacherPaymentTransferType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAra = json['nameAra'];
    nameEng = json['nameEng'];
  }
}
