import 'package:flutter/cupertino.dart';
import 'package:my_school/shared/cache_helper.dart';

import '../models/Quiz_model.dart';
import '../shared/components/components.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class QuizProvider with ChangeNotifier {
  List<Question> get items {
    return [...questions];
  }

  bool isLoading = true;
  List<Question> questions = null;
  String lang = CacheHelper.getData(key: 'lang');
  String token = CacheHelper.getData(key: 'token');
  Future<void> getData(int TeacherId, int QuizId) async {
    DioHelper.getData(
            url: "TeacherQuiz",
            query: {
              "TeacherId": TeacherId,
              "QuizId": QuizId,
            },
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        showToast(
            text: lang == "ar"
                ? "من فضلك قم بتسجيل الدخول مجدداً"
                : 'Session Expired, please login again',
            state: ToastStates.ERROR);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }

      questions = QuizModel.fromJson(value.data['data']).Questions;
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> DeleteQuestion(int TeacherId, int QuestionId) async {
    isLoading = true;
    notifyListeners();
    DioHelper.postData(
            url: "TeacherQuiz/DeleteQuestion",
            lang: lang,
            token: token,
            data: {},
            query: {"TeacherId": TeacherId, 'QuestionId': QuestionId})
        .then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        showToast(
            text: lang == "ar"
                ? "من فضلك قم بتسجيل الدخول مجدداً"
                : 'Session Expired, please login again',
            state: ToastStates.ERROR);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
      questions = QuizModel.fromJson(value.data['data']).Questions;
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  Future<void> saveQuestion(
      {context, Question question, int TeacherId, int QuizId}) {
    DioHelper.postData(
        url: "TeacherQuiz/SaveQuestion",
        lang: lang,
        token: token,
        data: question.toJson(),
        query: {
          "TeacherId": TeacherId,
          "QuizId": QuizId,
          "QuestionId": question.id
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        showToast(
            text: lang == "ar"
                ? "من فضلك قم بتسجيل الدخول مجدداً"
                : 'Session Expired, please login again',
            state: ToastStates.ERROR);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        questions = QuizModel.fromJson(value.data['data']).Questions;
        isLoading = false;
        notifyListeners();
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void ReorderQuestions(context, int TeacherId, int QuizId, String ids) async {
    //isLoading = true;
    // var questionsCopy = [...questions];
    // List<Question> questionsNew = [];
    // ids.split(',').forEach((id) {
    //   var myQuestion = questionsCopy.firstWhere((element) => element.id == id);
    //   questionsNew.add(myQuestion);
    // });
    // questions = questionsNew;
    // notifyListeners();
    DioHelper.postData(
        url: "TeacherQuiz/ReorderQuestions",
        lang: lang,
        token: token,
        data: {},
        query: {
          "TeacherId": TeacherId,
          'QuestionsList': ids,
          "QuizId": QuizId
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      } else {
        questions = QuizModel.fromJson(value.data['data']).Questions;
        notifyListeners();

        // notifyListeners();
        showToast(text: value.data["message"], state: ToastStates.SUCCESS);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }
}
