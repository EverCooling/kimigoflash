import 'package:dio/dio.dart';
import 'package:kimiflash/http/api/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final String _baseUrl = 'https://tms-qa.kimigoshop.com/'; // 替换为你的 API 基础 URL
  final Logger _logger = Logger();

  ApiService._internal() {
    // 初始化 Dio 实例
    BaseOptions options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    );

    _dio = Dio(options);

    // 添加拦截器
    _addInterceptors();
  }

  // 添加拦截器
  void _addInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 检查网络连接
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          return handler.reject(DioException(
            requestOptions: options,
            error: '网络连接失败',
            type: DioExceptionType.unknown,
          ));
        }

        // 添加 Token 到 headers
        final token = await _getToken();
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // 添加其他公共 headers
        options.headers['Accept'] = 'application/json';

        _logger.i('请求: ${options.uri}\nHeaders: ${options.headers}\nData: ${options.data}');
        return handler.next(options);
      },
    ));

    // 响应拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        _logger.i('响应: ${response.requestOptions.uri}\n状态码: ${response.statusCode}\n数据: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e('错误: ${e.requestOptions.uri}\n错误信息: ${e.message}\n堆栈: ${e.stackTrace}');

        // 统一处理错误
        _handleError(e);
        return handler.next(e);
      },
    ));
  }

  // 获取 Token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 保存 Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // 清除 Token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }


  // 获取 Token
  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  // 保存 Token
  Future<void> saveUsername(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', token);
  }

  // 清除 Token
  Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  // 处理错误
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('连接超时');
        break;
      case DioExceptionType.sendTimeout:
        print('发送超时');
        break;
      case DioExceptionType.receiveTimeout:
        print('接收超时');
        break;
      case DioExceptionType.badResponse:
      // 处理 HTTP 错误状态码
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          // Token 失效，处理登出逻辑
          print('Token 失效，需要重新登录');
        } else if (statusCode == 404) {
          print('请求资源不存在');
        } else if (statusCode == 500) {
          print('服务器内部错误');
        }
        break;
      case DioExceptionType.cancel:
        print('请求被取消');
        break;
      case DioExceptionType.unknown:
        print('未知错误');
        break;
      case DioExceptionType.badCertificate:
        print('证书验证失败');
        break;
      case DioExceptionType.connectionError:
        print('连接错误');
        break;
    }
  }

  // 通用 GET 请求
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 通用 POST 请求
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 通用 PUT 请求
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 通用 DELETE 请求
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}