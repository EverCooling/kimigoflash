import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String msg;
  final int? code;
  final String? token;

  ApiResponse({
    this.data,
    required this.success,
    required this.msg,
    this.code,
    this.token,
  });

  // 新增的通用解析方法
  static ApiResponse<dynamic> parse(dynamic response) {
    Map<String, dynamic> dataMap = {};
    bool isRawString = false;

    if (response is String) {
      try {
        // 判断是否为JSON字符串
        final decoded = json.decode(response);
        if (decoded is Map<String, dynamic>) {
          dataMap = decoded;
        } else {
          isRawString = true;
          dataMap['value'] = decoded.toString();
        }
      } catch (e) {
        // 非JSON字符串，视为原始字符串值
        dataMap['value'] = response;
        isRawString = true;
      }
    } else if (response is Map<String, dynamic>) {
      dataMap = response;
    } else {
      return ApiResponse.failure(msg: '无效的响应格式');
    }

    final code = isRawString ? 200 : dataMap['code'] as int? ?? 400;
    final success = isRawString || (dataMap['success'] as bool? ?? false);
    final msg = isRawString ? '请求成功' : dataMap['msg'] as String? ?? 'Request failed';
    final token = dataMap['token'] as String?;

    // 检查403状态码并处理
    if (code == 403) {
      _handleUnauthorized();
    }

    final data = _parseDataField(isRawString ? dataMap['value'] : (dataMap['data'] ?? dataMap));

    return ApiResponse<dynamic>(
      code: code,
      msg: msg,
      data: data,
      success: success,
      token: token,
    );
  }

  // 处理未授权状态（403）
  static void _handleUnauthorized() {
    // 显示提示信息
    Get.snackbar('登录过期', '您的会话已过期，请重新登录',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );

    // 延迟跳转以确保提示信息可见
    Future.delayed(const Duration(seconds: 2), () {
      // 使用GetX导航到登录页
      // 注意：需要确保您的路由配置中有名为'/login'的路由
      Get.offAllNamed('/login');
    });
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
  factory ApiResponse.success({T? data, String msg = "请求成功"}) {
    return ApiResponse<T>(
      code: 200,
      data: data,
      success: true,
      msg: msg,
    );
  }

  // 失败响应
  factory ApiResponse.failure({String msg = "请求失败", int? code}) {
    return ApiResponse<T>(
      data: null,
      success: false,
      msg: msg,
      code: code,
    );
  }

  // 从 JSON 解析（可选）
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonFunc) {
    try {
      final data = json['data'] != null ? fromJsonFunc(json['data']) : null;

      // 检查403状态码
      if (json['code'] == 403) {
        _handleUnauthorized();
      }

      return ApiResponse<T>(
        data: data,
        success: json['success'] ?? false,
        msg: json['msg'] ?? '未知错误',
        code: json['code'],
      );
    } catch (e) {
      return ApiResponse.failure(msg: '解析响应失败: $e');
    }
  }

  // 转为 JSON（可选）
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'success': success,
      'msg': msg,
      'code': code,
    };
  }
}