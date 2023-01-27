import 'package:my_school/models/user/student.dart';

abstract class StudentDashboardStates {}

class InitialState extends StudentDashboardStates {}

class LoadingState extends StudentDashboardStates {}

class SuccessState extends StudentDashboardStates {
  final Student student;

  SuccessState(this.student);
}

class ErrorState extends StudentDashboardStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentDashboardStates {}
