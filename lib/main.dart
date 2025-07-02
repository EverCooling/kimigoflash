import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'http/http_client.dart';
import 'route/app_pages.dart';

// 登录状态Provider
final isLoggedInProvider = StateProvider<bool>((ref) => false);

void main() async {
  // 初始化全局配置
  WidgetsFlutterBinding.ensureInitialized();

  // 检查登录状态
  final isLoggedIn = await ApiService().getToken() != '';

  runApp(
    ProviderScope(
      child: MyApp(
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // isLoggedInProvider.overrideWithValue(isLoggedIn),
      ],
      child: GetMaterialApp(
        // 根据登录状态设置初始路由
        initialRoute: isLoggedIn ? '/' : '/login',
        getPages: AppPages.pages,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(color: AppColors.redGradient[400]),
        ),
        defaultTransition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
        navigatorKey: Get.key,
        builder: (context, child) {
          return ProviderScope(
            parent: ProviderScope.containerOf(context),
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
