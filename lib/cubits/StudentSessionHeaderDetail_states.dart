import 'package:my_school/models/SchoolTypeYearOfStudy.dart';

abstract class StudentSessionHeaderDetailStates {}

class InitialState extends StudentSessionHeaderDetailStates {}

class LoadingState extends StudentSessionHeaderDetailStates {}

class SuccessState extends StudentSessionHeaderDetailStates {
  // final List<SchoolType> SchoolTypes;
  // final List<YearOfStudy> YearsOfStudies;
  // SuccessState(this.SchoolTypes, this.YearsOfStudies);
}

class ErrorState extends StudentSessionHeaderDetailStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentSessionHeaderDetailStates {}

class SavingRateState extends StudentSessionHeaderDetailStates {}

class RatingSavedState extends StudentSessionHeaderDetailStates {}

class PurchaseDoneState extends StudentSessionHeaderDetailStates {}
