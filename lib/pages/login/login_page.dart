import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: controller.username,
              decoration: InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1), // 改为1px
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1), // 统一宽度为1px
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: controller.password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1), // 改为1px
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1), // 统一宽度为1px
                ),
              ),
            ),
            SizedBox(height: 30),
            Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: controller.isLoading.value ? null : controller.login,
              child: controller.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('登录', style: TextStyle(fontSize: 18)),
            )),
          ],
        ),
      ),
    );
  }
}
