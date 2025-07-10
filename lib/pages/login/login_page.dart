import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../widgets/custom_text_field.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      fit: StackFit.loose,
      children: [
        // 背景图
        Image.asset(
          'assets/images/statusTopBg.png', // 替换为你自己的图片路径
          fit: BoxFit.scaleDown,
        ),
        // 原有登录内容（通常居中显示）
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 220),
                CustomTextField(
                  name: 'username',
                  enabled: true,
                  labelText: '用户名',
                  controller: controller.usernameController,
                  hintText: '请输入用户名',
                  prefixIcon: Icons.person,
                  onSuffixPressed: () async {

                  },
                  onSubmitted: (value) async {
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  name: 'password',
                  enabled: true,
                  labelText: '密码',
                  controller: controller.passwordController,
                  hintText: '请输入密码',
                  prefixIcon: Icons.password_outlined,
                  onSuffixPressed: () async {

                  },
                  onSubmitted: (value) async {
                  },
                ),
                SizedBox(height: 30),
                Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: controller.isLoading.value ? null : controller.login,
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('登录', style: TextStyle(fontSize: 18,color: Colors.redAccent)),
                )),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}
