class SchoolType {
  int Id;
  String NameEng;
  String NameAra;
  SchoolType({this.Id, this.NameAra, this.NameEng});
  SchoolType.fromJson(Map<String, dynamic> js) {
    this.Id = js["id"];
    this.NameEng = js["nameEng"];
    this.NameAra = js["nameAra"];
  }
}

class SchoolTypesAndYearsOfStudies {
  List<SchoolType> SchoolTypes = [];
  List<YearOfStudy> YearsOfStudies = [];
  SchoolTypesAndYearsOfStudies.fromJson(Map<String, dynamic> js) {
    js["schoolTypes"].forEach((j) {
      SchoolTypes.add(SchoolType.fromJson(j));
    });
    js["yearsOfStudies"].forEach((j) {
      YearsOfStudies.add(YearOfStudy.fromJson(j));
    });
  }
}

class YearOfStudy {
  int SchoolTypeId;
  int YearOfStudyId;
  String YearOfStudyAra;
  String YearOfStudyEng;
  YearOfStudy.fromJson(Map<String, dynamic> js) {
    SchoolTypeId = js["schoolTypeId"];
    YearOfStudyId = js["yearOfStudyId"];
    YearOfStudyAra = js["yearOfStudyAra"];
    YearOfStudyEng = js["yearOfStudyEng"];
  }
}
