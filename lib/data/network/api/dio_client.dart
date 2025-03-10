import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/logger.dart';
import '../../model/token_access.dart';
import 'constant/endpoints.dart';

class DioClient {
  // dio instance
  final Dio _dio = Dio();

  final Dio _refreshDio = Dio();

  getRefreshToken(userId, refreshToken) async {
    _refreshDio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.responseType = ResponseType.json;

    try {
      final Response response = await _refreshDio.post(
          Endpoints.getRefreshToken,
          data: {'userId': userId, 'refreshToken': refreshToken});

      var res = response.data as Map<String, dynamic>;
      return TokenAccess.fromMap(res);
    } catch (error) {
      rethrow;
    }
  }

  DioClient() {
    _dio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.responseType = ResponseType.json;

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('accessToken');
        if (token != null && token.isNotEmpty) {
          Logger.printLog('token $token');
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 403 ||
            error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          var refreshToken = prefs.getString('refreshToken');
          try {
            TokenAccess newAccess = await getRefreshToken(
                FirebaseAuth.instance.currentUser!.uid, refreshToken!);
            if (newAccess.success == true) {
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              sharedPreferences.setString(
                  'accessToken', newAccess.accessToken!);
              sharedPreferences.setString(
                  'refreshToken', newAccess.refreshToken!);
              _dio.options.headers['Authorization'] =
                  'Bearer ${newAccess.accessToken}';
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
          } catch (error) {
            Logger.printLog('refreshToken exception $error');
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Get
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post
  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Put
  Future<Response> put(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete
  Future<dynamic> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
