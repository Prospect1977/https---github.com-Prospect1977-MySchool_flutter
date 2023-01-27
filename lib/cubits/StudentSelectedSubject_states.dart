import 'package:my_school/models/StudentSubject.dart';

abstract class StudentSelectedSubjectsStates {}

class InitialState extends StudentSelectedSubjectsStates {}

class LoadingState extends StudentSelectedSubjectsStates {}

class SuccessState extends StudentSelectedSubjectsStates {
  final List<dynamic> studentSubjects;

  SuccessState(this.studentSubjects);
}

class ErrorState extends StudentSelectedSubjectsStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentSelectedSubjectsStates {}

class SavingState extends StudentSelectedSubjectsStates {}

class SuccessSavedState extends StudentSelectedSubjectsStates {}
