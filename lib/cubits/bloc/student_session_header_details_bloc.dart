// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
// import 'package:my_school/models/StudentSessionHeaderDetail.dart';
// import 'package:my_school/shared/cache_helper.dart';
// import 'package:my_school/shared/components/components.dart';

// import 'package:my_school/shared/dio_helper.dart';

// part 'student_session_header_details_event.dart';
// part 'student_session_header_details_state.dart';

// class StudentSessionHeaderDetailsBloc extends Bloc<
//     StudentSessionHeaderDetailsEvent, StudentSessionHeaderDetailsStates> {
//   int StudentId;
//   int SessionHeaderId;
//   StudentSessionHeaderDetailsBloc(this.StudentId, this.SessionHeaderId)
//       : super(InitialState()) {
//     AllData StudentSessionHeaderDetailsCollection;

//     var lang = CacheHelper.getData(key: "lang");
//     var token = CacheHelper.getData(key: "token");
//     on<StudentSessionHeaderDetailsEvent>((event, emit) async {
//       // Stream<StudentSessionHeaderDetailsStates> mapEventToState(
//       //     StudentSessionHeaderDetailsEvent event) async* {}
//       if (event is RefreshingEvent || event is LoadingEvent) {
//         emit(LoadingState());
//         await DioHelper.getData(
//                 url: 'StudentSessionHeaderDetails',
//                 query: {'Id': StudentId, 'SessionHeaderId': SessionHeaderId},
//                 lang: lang,
//                 token: token)
//             .then((value) {
//           print(value.data["data"]);

//           if (value.data["status"] == false) {
//             emit(UnAuthendicatedState());
//             return;
//           }
//           StudentSessionHeaderDetailsCollection =
//               AllData.fromJson(value.data["data"]);

//           emit(SuccessState(allData: StudentSessionHeaderDetailsCollection));
//         }).catchError((error) {
//           showToast(text: error.toString(), state: ToastStates.ERROR);

//           emit(ErrorState(error.toString()));
//         });
//       }
//     });
//     void postRate(StudentId, SessionHeaderId, Rate) {
//       //  emit(SavingRateState());
//       DioHelper.postData(
//               url: 'StudentSessionRate',
//               data: {},
//               query: {
//                 'StudentId': StudentId,
//                 'SessionHeaderId': SessionHeaderId,
//                 "Rate": Rate
//               },
//               lang: lang,
//               token: token)
//           .then((value) {
//         print(value.data["data"]);
//         if (value.data["status"] == false) {}

//         // emit(RatingSavedState());
//       }).catchError((error) {
//         showToast(text: error.toString(), state: ToastStates.ERROR);
//       });
//     }

//     void postPurchase(StudentId, SessionHeaderId) {
//       DioHelper.postData(
//               url: 'StudentPurchaseSession',
//               data: {},
//               query: {
//                 'StudentId': StudentId,
//                 'SessionHeaderId': SessionHeaderId,
//                 'DataDate': DateTime.now(),
//               },
//               lang: lang,
//               token: token)
//           .then((value) {
//         print(value.data["data"]);
//         if (value.data["status"] == false) {}

//         // emit(PurchaseDoneState());
//       }).catchError((error) {
//         showToast(text: error.toString(), state: ToastStates.ERROR);
//       });
//     }

//     void UpdateLessonProgress(StudentId, SessionHeaderId) {
//       DioHelper.postData(
//               url: 'StudentSessionHeaderDetails',
//               query: {
//                 'StudentId': StudentId,
//                 'SessionHeaderId': SessionHeaderId,
//                 "DataDate": DateTime.now()
//               },
//               lang: lang,
//               data: {},
//               token: token)
//           .then((value) {
//         print(value.data["data"]);
//       }).catchError((error) {
//         showToast(text: error.toString(), state: ToastStates.ERROR);
//       });
//     }
//   }
// }
