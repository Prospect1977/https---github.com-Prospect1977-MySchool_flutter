class StudentSubject {
  int SubjectId;
  int YearSubjectId;
  String SubjectName;
  bool Checked;
  int SortIndex;
  String dir;
  int ParentId;
  StudentSubject.fromJson(Map<String, dynamic> js) {
    SubjectId = js['SubjectId'];
    YearSubjectId = js['YearSubjectId'];
    SubjectName = js['SubjectName'];
    Checked = js['Checked'];
    SortIndex = js['SortIndex'];
    dir = js['dir'];
    ParentId = js['ParentId'];
  }
}

class TeacherSubject {
  int SubjectId;
  int YearSubjectId;
  String SubjectName;
  int SortIndex;
  String dir;
  int ParentId;
  bool Active;
  TeacherSubject.fromJson(Map<String, dynamic> js) {
    SubjectId = js['subjectId'];
    YearSubjectId = js['yearSubjectId'];
    SubjectName = js['subjectName'];
    SortIndex = js['sortIndex'];
    dir = js['dir'];
    ParentId = js['parentId'];
    Active = js['active'];
  }
}

class TeacherSubjects {
  List<TeacherSubject> Subjects = [];

  TeacherSubjects.fromJson(List<Object> js) {
    js.forEach((j) {
      Subjects.add(TeacherSubject.fromJson(j));
    });
  }
}
