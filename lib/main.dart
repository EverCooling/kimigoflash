import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'route/app_pages.dart';

void main() {
  runApp(
    ProviderScope(  // 外层ProviderScope
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/login',
      getPages: AppPages.pages,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(color:  AppColors.redGradient[400]),
      ),
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorKey: Get.key,
      builder: (context, child) {
        // 正确继承父级ProviderScope
        return ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}