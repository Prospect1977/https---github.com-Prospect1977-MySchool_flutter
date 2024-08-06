class Ticket {
  int id;
  String userId;
  DateTime publishDate;
  String fullName;
  String phoneNumber;
  String email;
  int studentId;
  String studentName;
  List<String> roles;
  String title;
  String description;
  String descriptionDir;
  String fileUrl;
  String urlSource;
  bool resolved;
  DateTime resolveDate;

  Ticket(
      {this.id,
      this.userId,
      this.publishDate,
      this.fullName,
      this.phoneNumber,
      this.email,
      this.studentId,
      this.studentName,
      this.roles,
      this.title,
      this.description,
      this.descriptionDir,
      this.fileUrl,
      this.urlSource,
      this.resolved,
      this.resolveDate});

  Ticket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    publishDate = json['publishDate'] != null
        ? DateTime.parse(json['publishDate'])
        : null;
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    studentId = json['studentId'];
    studentName = json['studentName'];
    roles = json['roles'].cast<String>();
    title = json['title'];
    description = json['description'];
    descriptionDir = json['descriptionDir'];
    fileUrl = json['fileUrl'];
    urlSource = json['urlSource'];
    resolved = json['resolved'];
    resolveDate = json['resolveDate'] != null
        ? DateTime.parse(json['resolveDate'])
        : null;
  }
}
