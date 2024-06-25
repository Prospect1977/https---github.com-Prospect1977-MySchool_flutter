import 'package:flutter/cupertino.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../models/Quiz_model.dart';
import '../shared/components/components.dart';
import '../shared/components/constants.dart';
import '../shared/components/functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizProvider with ChangeNotifier {
  List<Question> get items {
    return [...questions];
  }

  bool isLoading = true;
  List<Question> questions = null;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');

  Future<void> getData(int TeacherId, int QuizId) async {
    final url = Uri.parse(
      '${baseUrl}TeacherQuiz?TeacherId=$TeacherId&QuizId=$QuizId',
    );
    final response = await http.get(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    }

    questions = QuizModel.fromJson(value['data']).Questions;
    isLoading = false;
    notifyListeners();
  }

  Future<void> DeleteQuestion(int TeacherId, int QuestionId, context) async {
    isLoading = true;
    notifyListeners();
    var userId = CacheHelper.getData(key: 'userId');

    final url = Uri.parse(
      '${baseUrl}TeacherQuiz/DeleteQuestion?TeacherId=$TeacherId&QuestionId=$QuestionId&UserId=$userId',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      showToast(text: value["message"], state: ToastStates.SUCCESS);
      Navigator.of(context).pop();
    }
    questions = QuizModel.fromJson(value['data']).Questions;
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveQuestion(
      {context, Question question, int TeacherId, int QuizId}) async {
    var userId = CacheHelper.getData(key: 'userId');
    var url = Uri.parse(
      '${baseUrl}TeacherQuiz/SaveQuestion?TeacherId=$TeacherId&QuestionId=${question.id}&UserId=$userId&QuizId=$QuizId',
    );
    final response = await http.post(url,
        headers: {
          "lang": lang,
          'Authorization': 'Bearer $token',
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(question.toJson()));
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      showToast(
          text: lang == "ar"
              ? "من فضلك قم بتسجيل الدخول مجدداً"
              : 'Session Expired, please login again',
          state: ToastStates.ERROR);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      questions = QuizModel.fromJson(value['data']).Questions;
      isLoading = false;
      notifyListeners();
      Navigator.of(context).pop();
    }
    // DioHelper.postData(
    //     url: "TeacherQuiz/SaveQuestion",
    //     lang: lang,
    //     token: token,
    //     data: question.toJson(),
    //     query: {
    //       "TeacherId": TeacherId,
    //       "QuizId": QuizId,
    //       "QuestionId": question.id,
    //       "UserId": userId
    //     }).then((value) {
    //   if (value.data["status"] == false &&
    //       value.data["message"] == "SessionExpired") {
    //     showToast(
    //         text: lang == "ar"
    //             ? "من فضلك قم بتسجيل الدخول مجدداً"
    //             : 'Session Expired, please login again',
    //         state: ToastStates.ERROR);
    //     return;
    //   } else if (value.data["status"] == false) {
    //     showToast(text: value.data["message"], state: ToastStates.ERROR);
    //     return;
    //   } else {
    //     questions = QuizModel.fromJson(value.data['data']).Questions;
    //     isLoading = false;
    //     notifyListeners();
    //     Navigator.of(context).pop();
    //   }
    // }).catchError((error) {
    //   showToast(text: error.toString(), state: ToastStates.ERROR);
    // });
  }

  void ReorderQuestions(context, int TeacherId, int QuizId, String ids) async {
    var userId = CacheHelper.getData(key: 'userId');

    final url = Uri.parse(
      '${baseUrl}TeacherQuiz/ReorderQuestions?TeacherId=$TeacherId&QuestionsList=$ids&QuizId=$QuizId&UserId=$userId',
    );
    final response = await http.post(url, headers: {
      "lang": lang,
      'Authorization': 'Bearer $token',
    });
    final value = json.decode(response.body);
    if (value["status"] == false && value["message"] == "SessionExpired") {
      handleSessionExpired(context);
      return;
    } else if (value["status"] == false) {
      showToast(text: value["message"], state: ToastStates.ERROR);
      return;
    } else {
      questions = QuizModel.fromJson(value['data']).Questions;
      notifyListeners();

      // notifyListeners();
      showToast(text: value["message"], state: ToastStates.SUCCESS);
    }
  }
}
