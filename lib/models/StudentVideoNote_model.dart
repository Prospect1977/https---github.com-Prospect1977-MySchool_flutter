class StudentVideoNote {
  int id;
  int studentId;
  int videoId;
  int time;
  String note;

  StudentVideoNote.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentId = json['studentId'];
    videoId = json['videoId'];
    time = json['time'];
    note = json['note'];
  }
}

class StudentVideoNotes {
  List<StudentVideoNote> items = [];
  StudentVideoNotes.fromJson(List<Object> json) {
    json.forEach((element) {
      items.add(StudentVideoNote.fromJson(element));
    });
  }
}
