part of 'student_session_header_details_bloc.dart';

@immutable
abstract class StudentSessionHeaderDetailsStates {}

class InitialState extends StudentSessionHeaderDetailsStates {}

class LoadingState extends StudentSessionHeaderDetailsStates {}

class RefreshingState extends StudentSessionHeaderDetailsStates {}

class SuccessState extends StudentSessionHeaderDetailsStates {
  AllData allData=null;
  SuccessState({this.allData});
}

class ErrorState extends StudentSessionHeaderDetailsStates {
  final String error;

  ErrorState(this.error);
}

class UnAuthendicatedState extends StudentSessionHeaderDetailsStates {}

class SavingRateState extends StudentSessionHeaderDetailsStates {}

class RatingSavedState extends StudentSessionHeaderDetailsStates {}

class PurchaseDoneState extends StudentSessionHeaderDetailsStates {}
