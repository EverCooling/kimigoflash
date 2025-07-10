import 'dart:developer' as Get;
import 'dart:io';
import 'package:get/get_connect/http/src/multipart/form_data.dart' hide FormData;
import 'package:kimiflash/http/api/api_response.dart';
import 'package:kimiflash/http/http_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // 用于MultipartRequest
import 'package:dio/dio.dart'; // 用于访问dio实例

class AuthApi {
  // 使用单例实例
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

  //异常登记校验接口
  Future<ApiResponse> checkOrderAbnormalRegister(Map<String,dynamic> queryParameters) async {
    try {
      final response = await _client.post(
          '/delivery-man/delivery-man-check-order-abnormal-register',
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

  //签收校验接口
  Future<ApiResponse> CheckOrderIsDeliver(Map<String,dynamic> queryParameters) async {
    try {
      final response = await _client.post(
        '/delivery-man/delivery-man-check-order-delivery',
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

  //出仓扫描批量提交
  Future<ApiResponse> DeliveryManBatchOutWarehouse(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
        '/delivery-man/delivery-man-batch-out-warehouse',
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

  //签收扫描提交接口
  Future<ApiResponse> DeliveryManAddOrderDelivery(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
        '/delivery-man/delivery-man-add-order-delivery',
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

  //派送异常登记
  Future<ApiResponse> DeliveryManAbnormalRegister(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
        'delivery-man/add-delivery-man-abnormal-register',
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


  //签收扫描提交接口
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


  // 上传单个文件
  Future<ApiResponse> uploadFile(File file,
      {Map<String, dynamic>? queryParameters,
        Function(int, int)? onSendProgress}) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _client.post(
        'https://admapi.qa.kimigoshop.com/api/Upload/ImportData',
        data: formData,
        queryParameters: queryParameters,
      );
      return ApiResponse.parse(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 上传多个文件
  Future<ApiResponse> uploadFiles(List<File> files,
      {Map<String, dynamic>? queryParameters,
        Function(int, int)? onSendProgress}) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (var file in files) {
        multipartFiles.add(await MultipartFile.fromFile(file.path));
      }

      FormData formData = FormData.fromMap({
        'files': multipartFiles,
      });

      final response = await _client.post(
        'https://admapi.qa.kimigoshop.com/api/Upload/ImportData',
        data: formData,
        queryParameters: queryParameters,
      );
      return ApiResponse.parse(response.data);
    } catch (e) {
      rethrow;
    }
  }

//查询派送列表
  Future<ApiResponse> DeliverManQueryDeliveryList(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
          '/delivery-man/delivery-man-query-delivery-list',
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

  //查询派送列表
  Future<ApiResponse> DeliverManDeliveryDetail(Map<String,dynamic> queryParameters) async{
    print(queryParameters);
    try {
      final response = await _client.post(
          '/delivery-man/delivery-man-delivery-detail',
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

  //查询派送列表
  Future<ApiResponse> AddDeliveryManAbnormalRegister(Map<String,dynamic> queryParameters) async{
    try {
      final response = await _client.post(
          '/delivery-man/add-delivery-man-abnormal-register',
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
}

