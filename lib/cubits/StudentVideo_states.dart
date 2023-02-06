import 'package:my_school/models/SchoolTypeYearOfStudy.dart';

abstract class StudentVideoStates {}

class InitialState extends StudentVideoStates {}

class LoadingState extends StudentVideoStates {}

class SuccessState extends StudentVideoStates {
  // final List<SchoolType> SchoolTypes;
  // final List<YearOfStudy> YearsOfStudies;
  // SuccessState(this.SchoolTypes, this.YearsOfStudies);
}

class ErrorState extends StudentVideoStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentVideoStates {}

class SavingState extends StudentVideoStates {}
