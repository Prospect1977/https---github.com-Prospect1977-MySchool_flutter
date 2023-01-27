import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentDailySchedule_states.dart';
import 'package:my_school/models/StudentDailySchedule_model.dart' as m;
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/dio_helper.dart';

class StudentDailyScheduleCubit extends Cubit<StudentDailyScheduleStates> {
  StudentDailyScheduleCubit() : super(InitialState());
  static StudentDailyScheduleCubit get(context) => BlocProvider.of(context);

  m.DailySchedule DailySchedule;

  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  int TodaysDateIndex = 0;

  void getData(int Id) {
    emit(LoadingState());
    DioHelper.getData(
            url: 'StudentDailySchedule',
            query: {"Id": Id},
            lang: lang,
            token: token)
        .then((value) {
      print(value.data["data"]);

      if (value.data["status"] == false) {
        emit(UnAuthendicatedState());
        return;
      }
      var tempDailySchedule = m.DailySchedule.fromJson(value.data['data']);
      var now = new DateTime.now();
      var i = 0;
      while (i < tempDailySchedule.items.length) {
        if (tempDailySchedule.items[i].dataDate.day == now.day &&
            tempDailySchedule.items[i].dataDate.month == now.month &&
            tempDailySchedule.items[i].dataDate.year == now.year) {
          TodaysDateIndex = i;
        }
        i++;
      }
      DailySchedule = tempDailySchedule;
      emit(SuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ErrorState(error.toString()));
    });
  }
}
