// lib/pages/completed_delivery/completed_delivery_list_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class CompletedDeliveryListController extends GetxController {
  final trackingNumber = ''.obs;
  String? selectedDate;
  final selectedMethod = '全部'.obs;

  final deliveryMethods = ['全部', '上门', '自提柜自提'];
  final allItems = <Map<String, dynamic>>[
    {
      'trackingNumber': '20231001001',
      'recipientName': '张三',
      'address': '北京市朝阳区XX街道XX号',
      'deliveryMethod': '上门',
      'signed': true,
    },
    {
      'trackingNumber': '20231001002',
      'recipientName': '李四',
      'address': '上海市浦东新区XX路XX弄',
      'deliveryMethod': '自提柜自提',
      'signed': false,
    },
    {
      'trackingNumber': '20231001003',
      'recipientName': '王五',
      'address': '广州市天河区XX大道XX号',
      'deliveryMethod': '上门',
      'signed': true,
    },
  ];

  var filteredItems = <Map<String, dynamic>>[].obs;

  void filterItems() {
    filteredItems.value = allItems.where((item) {
      final bool matchMethod =
          selectedMethod.value == '全部' || item['deliveryMethod'] == selectedMethod.value;
      final bool matchTracking = trackingNumber.value.isEmpty ||
          (item['trackingNumber']?.toString() ?? '').contains(trackingNumber.value);
      return matchMethod && matchTracking;
    }).toList();
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      filterItems();
    }
  }

  void navigateToExceptionReport(String trackingNumber) {
    Get.toNamed('/exception-report', arguments: {'trackingNumber': trackingNumber});
  }

  void markAsSigned(Map<String, dynamic> item) {
    item['signed'] = true;
    filterItems(); // 刷新列表
  }

  @override
  void onInit() {
    super.onInit();
    filterItems(); // 初始化时加载数据
  }
}
