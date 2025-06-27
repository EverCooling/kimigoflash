import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/api_response.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/http/http_client.dart';
import '../../http/http_response_provider.dart';
import '../../http/api/token_manager.dart';

class LoginController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> login() async {
    final container = ProviderScope.containerOf(Get.context!);
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('错误', '用户名或密码不能为空');
      return;
    }
    isLoading.value = true;

    try {
      // 直接调用auth_api登录接口
      final authApi = AuthApi();
      final result = await authApi.login(username, password);

      if (result.code == 200) {
        print(result.msg);
        // 保存token
        await ApiService().saveToken(result.msg);
        await ApiService().saveUsername(username); // 新增：保存用户名
        isLoading.value = false;
        Get.offAllNamed('/home');
      } else {
        isLoading.value = false;
        Get.snackbar('登录失败', result.msg ?? '未知错误');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('错误', e.toString());
    }
  }
}
