import 'package:kimiflash/http/api/auth_api.dart';

void performLogin() async {
  final authApi = AuthApi();
  try {
    final result = await authApi.login("john_doe", "secure_password_123");
    print("登录成功: $result");
  } catch (e) {
    print("登录失败: $e");
  }
}
