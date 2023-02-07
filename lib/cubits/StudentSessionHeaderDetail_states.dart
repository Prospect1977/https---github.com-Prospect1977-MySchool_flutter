import 'package:my_school/models/SchoolTypeYearOfStudy.dart';
import 'package:my_school/models/StudentSessionHeaderDetail.dart';

abstract class StudentSessionHeaderDetailStates {}

class InitialState extends StudentSessionHeaderDetailStates {}

class LoadingState extends StudentSessionHeaderDetailStates {}

class SuccessState extends StudentSessionHeaderDetailStates {
  final AllData allData;
  SuccessState(this.allData);
}

class ErrorState extends StudentSessionHeaderDetailStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentSessionHeaderDetailStates {}

class SavingRateState extends StudentSessionHeaderDetailStates {}

class RatingSavedState extends StudentSessionHeaderDetailStates {}

class PurchaseDoneState extends StudentSessionHeaderDetailStates {}
