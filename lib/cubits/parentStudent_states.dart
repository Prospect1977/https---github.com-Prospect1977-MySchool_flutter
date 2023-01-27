import 'package:my_school/models/user/student.dart';

abstract class ParentStudentStates {}

class InitialState extends ParentStudentStates {}

class LoadingState extends ParentStudentStates {}

class SuccessState extends ParentStudentStates {
  final List<dynamic> students;

  SuccessState(this.students);
}

class ErrorState extends ParentStudentStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends ParentStudentStates {}
