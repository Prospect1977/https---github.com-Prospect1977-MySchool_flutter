import 'package:my_school/models/SchoolTypeYearOfStudy.dart';

abstract class StudentYearOfStudyStates {}

class InitialState extends StudentYearOfStudyStates {}

class LoadingState extends StudentYearOfStudyStates {}

class SuccessState extends StudentYearOfStudyStates {
  // final List<SchoolType> SchoolTypes;
  // final List<YearOfStudy> YearsOfStudies;
  // SuccessState(this.SchoolTypes, this.YearsOfStudies);
}

class ErrorState extends StudentYearOfStudyStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentYearOfStudyStates {}

class SavingState extends StudentYearOfStudyStates {}
