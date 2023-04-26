import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_school/shared/components/constants.dart' as con;

class DioHelper {
  static Dio dio;
  static Dio dio0; //root address (without /api)

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: con.baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    dio0 = Dio(
      BaseOptions(
        baseUrl: con.baseUrl0,
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    @required String url,
    @required Map<String, dynamic> query,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
    };

    return await dio.get(
      url,
      queryParameters: query,
    );
  }

  static Future<Response> postData({
    @required String url,
    Map<String, dynamic> query,
    dynamic data,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return dio.post(
      url,
      queryParameters: query,
      data: data,
    );
  }

  static Future<Response> postImage({
    @required String url,
    Map<String, dynamic> query,
    dynamic data,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
      'Accept': '*/*',
    };

    return dio.post(url,
        queryParameters: query,
        data: data,
        onSendProgress: (int sent, int total) {});
  }

  static Future<Response> postVideo(
      {@required String url,
      Map<String, dynamic> query,
      dynamic data,
      String lang = 'ar',
      String token,
      Function updateProgress}) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
      'Accept': '*/*',
    };

    return dio.post(url, queryParameters: query, data: data,
        onSendProgress: (int sent, int total) {
      updateProgress(sent, total);
      print(
          '--------------------------------------------------$sent of --- $total');
    });
  }

  static Future<Response> updateData({
    @required String url,
    Map<String, dynamic> query,
    Map<String, dynamic> data,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return dio.put(
      url,
      queryParameters: query,
      data: data,
    );
  }

  static Future<Response> deleteData({
    @required String url,
    Map<String, dynamic> query,
    Map<String, dynamic> data,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return dio.delete(
      url,
      queryParameters: query,
      data: data,
    );
  }

  static Future<Response> postDataForLogin({
    @required String url,
    @required Map<String, dynamic> data,
    String lang = 'ar',
    String token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dio.post(
      url,
      data: data,
    );
  }
}
