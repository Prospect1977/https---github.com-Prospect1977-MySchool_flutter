import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_school/shared/components/constants.dart';

class DioHelper {
  static Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
        },
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
      queryParameters: query,
      data: data,
    );
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
      'Authorization': '111',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dio.post(
      url,
      data: data,
    );
  }
}
