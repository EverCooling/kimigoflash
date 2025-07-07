import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/token_manager.dart';
import 'package:kimiflash/http/http_client.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('首页')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog, // 改为显示确认对话框
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1,
          children: controller.features.map((feature) {
            return FeatureCard(feature: feature);
          }).toList(),
        ),
      ),
    );
  }

  // 显示退出登录确认对话框
  void _showLogoutDialog() {
    Get.defaultDialog(
      title: '退出登录',
      middleText: '确定要退出当前账号吗？',
      confirm: ElevatedButton(
        onPressed: _performLogout,
        child: Text('确认'),
      ),
      cancel: ElevatedButton(
        onPressed: Get.back, // 取消按钮，关闭对话框
        child: Text('取消'),
      ),
      buttonColor: AppColors.redGradient[300],
      confirmTextColor: Colors.white,
      cancelTextColor: AppColors.redGradient[300],
    );
  }

  // 执行退出登录操作
  void _performLogout() {
    // 清除 GetX 控制器
    Get.delete<HomeController>();
    // 跳转到登录页
    Get.offAllNamed('/login');
    ApiService().clearToken();
  }
}

class FeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  const FeatureCard({required this.feature, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => feature['onTap'] is Function ? feature['onTap']() : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature['icon'],
              size: 46,
              color: AppColors.redGradient[300],
            ),
            SizedBox(height: 4),
            Text(
              feature['title'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}