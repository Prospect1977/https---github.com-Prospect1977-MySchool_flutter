import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_school/cubits/StudentSessionHeaderDetail_states.dart';
import 'package:my_school/models/StudentLessonSessions_model.dart';
import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
import 'package:my_school/models/StudentSessionHeaderDetail.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentSessionHeaderDetailCubit
    extends Cubit<StudentSessionHeaderDetailStates> {
  StudentSessionHeaderDetailCubit() : super(InitialState());
  static StudentSessionHeaderDetailCubit get(context) =>
      BlocProvider.of(context);
  AllData StudentSessionHeaderDetailsCollection;

  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");

  void getSessionDetails(StudentId, SessionHeaderId) {
    emit(LoadingState());
    DioHelper.getData(
            url: 'StudentSessionHeaderDetails',
            query: {'Id': StudentId, 'SessionHeaderId': SessionHeaderId},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {
        emit(UnAuthendicatedState());
        return;
      }
      StudentSessionHeaderDetailsCollection =
          AllData.fromJson(value.data["data"]);

      emit(SuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }

  void postRate(StudentId, SessionHeaderId, Rate) {
    emit(SavingRateState());
    DioHelper.postData(
            url: 'StudentSessionRate',
            data: {},
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              "Rate": Rate
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {}

      emit(RatingSavedState());
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }

  void postPurchase(StudentId, SessionHeaderId) {
    DioHelper.postData(
            url: 'StudentPurchaseSession',
            data: {},
            query: {
              'StudentId': StudentId,
              'SessionHeaderId': SessionHeaderId,
              'DataDate': DateTime.now(),
            },
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {}

      emit(PurchaseDoneState());
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }
}
