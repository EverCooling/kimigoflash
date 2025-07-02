import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../http/api/auth_api.dart';
import '../widgets/loading_manager.dart';

class DeliveryListController extends GetxController  with GetTickerProviderStateMixin{
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    dispose();
    super.onClose();
  }

  void navigateToDetail(Map<String, dynamic> order, String type) {
    // 根据类型导航到不同的详情页
    switch (type) {
      case 'pending':
        Get.toNamed('/pending-delivery-detail', arguments: order);
        break;
      case 'completed':
        Get.toNamed('/complete-delivery-detail', arguments: order);
        break;
      case 'failed':
        // Get.toNamed('/delivery/failed_detail', arguments: order);
        break;
      default:
        Get.snackbar('错误', '未知的订单类型');
    }
  }
}
