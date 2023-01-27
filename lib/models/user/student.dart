import 'package:flutter/material.dart';

class Student {
  int Id;
  String FullName;
  String Gender;
  int SchoolTypeId;
  int YearOfStudyId;
  // Student({
  //   @required this.id,
  //   @required this.fullName,
  // });
  Student.fromJson(Map json) {
    this.Id = json["Id"];
    this.FullName = json["FullName"];
    this.Gender = json["Gender"];

    this.SchoolTypeId = json["SchoolTypeId"];
    this.YearOfStudyId = json["YearOfStudyId"];
  }
  Student.fromJsonCamelCase(Map json) {
    this.Id = json["id"];
    this.FullName = json["fullName"];
    this.Gender = json["gender"];
    this.SchoolTypeId = json["schoolTypeId"];
    this.YearOfStudyId = json["yearOfStudyId"];
  }
}
