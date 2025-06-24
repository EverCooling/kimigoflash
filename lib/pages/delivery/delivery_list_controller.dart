import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryListController extends GetxController  with GetTickerProviderStateMixin{
  late TabController tabController;

  // 模拟数据
  final List<Map<String, dynamic>> pendingList = [
    {
      'trackingNumber': '20231001001',
      'deliveryMethod': '上门',
      'orderSource': '平台A',
      'recipientName': '张三',
      'recipientPhone': '13800001111',
      'address': '北京市朝阳区XX街道XX号'
    },
    {
      'trackingNumber': '20231001002',
      'deliveryMethod': '自提柜自提',
      'orderSource': '平台B',
      'recipientName': '李四',
      'recipientPhone': '13900002222',
      'address': '上海市浦东新区XX路XX弄'
    },
  ].obs;

  final List<Map<String, dynamic>> completedList = [
    {
      'trackingNumber': '20231001003',
      'deliveryMethod': '上门',
      'orderSource': '平台C',
      'recipientName': '王五',
      'recipientPhone': '13700003333',
      'address': '广州市天河区XX大道XX号'
    },
  ].obs;

  final List<Map<String, dynamic>> failedList = [
    {
      'trackingNumber': '20231001004',
      'deliveryMethod': '上门',
      'orderSource': '平台D',
      'recipientName': '赵六',
      'recipientPhone': '13600004444',
      'address': '深圳市南山区XX科技园XX栋'
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    // ✅ 记得释放资源
    tabController.dispose();
    super.onClose();
  }

  void navigateToDetail(Map<String, dynamic> item, String status) {
    if (status == 'pending') {
      Get.toNamed('/pending-delivery-detail', arguments: {
        'trackingNumber': 'SF123456789CN',
      });
      // Get.toNamed('/pending-delivery-detail', arguments: {'item': item});
    } else if (status == 'completed') {
      Get.toNamed('/complete-delivery-detail', arguments: {'item': item});
    } else if (status == 'failed') {
      Get.toNamed('/exception-report', arguments: {'trackingNumber': item['trackingNumber']});
    }
  }
}
