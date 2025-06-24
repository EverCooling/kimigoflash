class ApiResponse<T> {
  final T? data;
  final bool success;
  final String message;
  final int? code;

  ApiResponse({
    this.data,
    required this.success,
    required this.message,
    this.code,
  });

  // 新增的通用解析方法
  static ApiResponse<dynamic> parse(Map<String, dynamic> response) {
    final code = response['code'] as int? ?? 400;
    final success = response['success'] as bool? ?? false;
    final message = response['message'] as String? ?? 'Request failed';

    final data = _parseDataField(response['data']);

    return ApiResponse<dynamic>(
      code: code,
      message: message,
      data: data,
      success: success,
    );
  }

// 数据字段解析方法
  static dynamic _parseDataField(dynamic data) {
    if (data == null) {
      return null;
    }

    // 支持Map类型
    if (data is Map<String, dynamic>) {
      return data;
    }

    // 支持基本数据类型
    if (data is int || data is double || data is String || data is bool) {
      return {'value': data};
    }

    return data;
  }

  // 成功响应
  factory ApiResponse.success({T? data, String message = "请求成功"}) {
    return ApiResponse<T>(
      code: 200,
      data: data,
      success: true,
      message: message,
    );
  }

  // 失败响应
  factory ApiResponse.failure({String message = "请求失败", int? code}) {
    return ApiResponse<T>(
      data: null,
      success: false,
      message: message,
      code: code,
    );
  }

  // 从 JSON 解析（可选）
  factory ApiResponse.fromJson(Map<String, dynamic> json,
      T Function(dynamic) fromJsonFunc) {
    try {
      final data = json['data'] != null ? fromJsonFunc(json['data']) : null;
      return ApiResponse<T>(
        data: data,
        success: json['success'] ?? false,
        message: json['message'] ?? '未知错误',
        code: json['code'],
      );
    } catch (e) {
      return ApiResponse.failure(message: '解析响应失败: $e');
    }
  }

  // 转为 JSON（可选）
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'success': success,
      'message': message,
      'code': code,
    };
  }
}
