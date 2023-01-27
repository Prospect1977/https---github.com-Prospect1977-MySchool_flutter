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
