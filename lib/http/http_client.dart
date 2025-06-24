import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kimiflash/http/http_exception.dart'; // 可选自定义异常类
import 'package:kimiflash/http/api/token_manager.dart'; // 导入TokenManager
import 'token_interceptor.dart'; // 修复TokenInterceptor的导入路径

class HttpClient {
  final Ref? ref;
  final ProviderContainer? container; // 添加ProviderContainer参数
  late Dio _dio;

  factory HttpClient([Ref? ref, ProviderContainer? container]) {
    return HttpClient._internal(ref, container);
  }

  HttpClient._internal(Ref? r, ProviderContainer? c) : ref = r, container = c {
    // 初始化 Dio 实例
    _dio = Dio(BaseOptions(
      baseUrl: "https://admapi.qa.kimigoshop.com/", // 设置你的基础 URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ));

    // 添加拦截器（可选）
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    _dio.interceptors.add(TokenInterceptor());
  }

  // 获取原始 Dio 实例（用于高级操作）
  Dio get dio => _dio;

  // GET 请求
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 发送POST请求
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.post(endpoint, data: data, options: Options(headers: headers));
      return response.data;
    } on DioException catch (e) {
      // 处理 Dio 异常
      throw HttpException(message: e.message?.toString() ?? 'Unknown error', statusCode: e.response?.statusCode ?? 0);
    } catch (e) {
      // 处理其他异常
      throw Exception('Unknown error: $e');
    }
  }

  // PUT 请求
  Future<dynamic> put(String path, dynamic data, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 请求
  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 处理响应数据
  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw HttpException(message: "HTTP Error [${response.statusCode}]", statusCode: response.statusCode);
    }
  }

  // 处理异常
  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return HttpException(message: "请求超时，请检查网络");
    } else if (e.type == DioExceptionType.connectionError) {
      return HttpException(message: "网络连接异常");
    } else if (e.response != null) {
      return HttpException(message: e.message.toString(), statusCode: e.response?.statusCode);
    } else {
      return HttpException(message: e.message.toString());
    }
  }
}
