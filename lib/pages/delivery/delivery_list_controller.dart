import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';

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

  void navigateToDetail(Map<String, dynamic> order, DeliveryStatus type) {
    // 根据类型导航到不同的详情页
    switch (type) {
      case DeliveryStatus.pending:
        Get.toNamed('/pending-delivery-detail', arguments: order);
        break;
      case DeliveryStatus.delivered:
        Get.toNamed('/complete-delivery-detail', arguments: order);
        break;
      case DeliveryStatus.failed:
        Get.toNamed('/failed-delivery-detail', arguments: order);
        // Get.toNamed('/delivery/failed_detail', arguments: order);
        break;
      default:
        Get.snackbar('错误', '未知的订单类型');
    }
  }
}
