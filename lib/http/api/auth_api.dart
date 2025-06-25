import 'package:kimiflash/http/api/api_response.dart';
import 'package:kimiflash/http/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kimiflash/http/api/token_manager.dart';
import 'package:dio/dio.dart'; // 添加Dio导入
import 'dart:convert';
import 'package:http/http.dart' as http; // 用于MultipartRequest
import 'package:kimiflash/http/api/api_response.dart';
import 'package:kimiflash/http/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kimiflash/http/api/token_manager.dart';

class AuthApi {
  final ApiService _client = ApiService();

// 修改后的接口调用示例
  Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await _client.post(
        '/delivery-man/login', 
        data: {
          'username': username,
          'password': password,
        }
      );
      return ApiResponse.parse(response.data);
    } catch (e) {
      return ApiResponse.failure(msg: e.toString());
    }
  }


//签收校验接口
  Future<ApiResponse> CheckOrderIsDeliver(String orderNumber) async {
    try {
      final response = await _client.get(
        '/api/DeliveryMan/CheckOrderIsDeliver',
        queryParameters: {
          'kyInStorageNumber': orderNumber,
        }
      );

      // 使用ApiResponse.parse方法解析响应
      return ApiResponse.parse(response.data);
    } catch (e) {
      return ApiResponse.failure(
        msg: '验证出错: ${e.toString()}',
        code: 500,
      );
    }
  }

  //签收提交接口
  Future<ApiResponse> DeliverSignFor(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
        '/api/DeliveryMan/DeliverSignFor',
        data: queryParameters,
      );

      // 使用ApiResponse.parse方法解析响应
      return ApiResponse.parse(response.data);
    } catch (e) {
      return ApiResponse.failure(
        msg: '验证出错: ${e.toString()}',
        code: 500,
      );
    }
  }

  //签收提交接口
  Future<ApiResponse> DeliverManScanOutWarehouse(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
        '/delivery-man/delivery-man-scan-out-warehouse',
        data: queryParameters
      );

      // 使用ApiResponse.parse方法解析响应
      return ApiResponse.parse(response.data);
    } catch (e) {
      return ApiResponse.failure(
        msg: '验证出错: ${e.toString()}',
        code: 500,
      );
    }
  }

  //Todo  使用http包实现的独立上传图片方法
  Future<ApiResponse> uploadImage(String filepath) async {
    try {
      final url = Uri.parse('http://114.55.176.141:8081/api/Upload/ImportData');
      final request = http.MultipartRequest('POST', url)
        ..fields['filepath'] = filepath
        ..fields['name'] =  'file'
        ..fields['formData'];


      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // 假设返回的是JSON格式字符串，需要根据实际接口响应调整解析逻辑
      final parsedResponse = jsonDecode(responseBody);

      return ApiResponse.parse(parsedResponse);
    } catch (e) {
      return ApiResponse.failure(
        msg: 'HTTP上传出错: ${e.toString()}',
        code: 500,
      );
    }
  }
}

