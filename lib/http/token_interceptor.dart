import 'package:dio/dio.dart';
import 'package:kimiflash/http/api/token_manager.dart';

class TokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, 
      RequestInterceptorHandler handler) async {
    // 获取保存的token
    final token = await TokenManager.getToken();
    
    // 如果存在token，则添加到请求头
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 处理响应数据
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理错误
    super.onError(err, handler);
  }
}