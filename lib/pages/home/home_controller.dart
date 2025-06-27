import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  final List<Map<String, dynamic>> features = [
    {
      'title': '出仓扫描',
      'route': '/outbound-scan',
      'icon': Icons.qr_code_scanner_outlined,
      'onTap': navigateToOutboundScan,
    },
    {
      'title': '派送列表',
      'route': '/delivery-list',
      'icon': Icons.list_alt,
      'onTap': navigateToDeliveryList,
    },
    {
      'title': '签收扫描',
      'route': '/sign-receipt-scan',
      'icon': Icons.edit_document,
      'onTap': navigateToSignReceiptScan,
    },
    {
      'title': '异常登记',
      'route': '/exception-report',
      'icon': Icons.warning_amber_rounded,
      'onTap': navigateToExceptionReport,
    },
  ];

  static void navigateToOutboundScan() => Get.toNamed('/outbound-scan');
  static void navigateToDeliveryList() => Get.toNamed('/delivery-list');
  static void navigateToSignReceiptScan() => Get.toNamed('/sign-receipt-scan');
  static void navigateToExceptionReport() => Get.toNamed('/exception-report');

  void navigateTo(String route) {
    Get.toNamed(route);
  }
}
