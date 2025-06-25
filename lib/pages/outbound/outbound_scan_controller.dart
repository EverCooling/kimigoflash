import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../http/api/token_manager.dart';

class OutboundScanController extends GetxController {
  // 使用 Rx<String?> 来确保 Obx 可以监听变化
  var selectedCourier = Rx<String?>(null);

  final List<String> couriers = ['张三', '李四', '王五'];

  final scanController = TextEditingController();
  final courierController = TextEditingController();

  // 使用 RxList 替代普通 List
  final scannedList = <String>[].obs;
  final uploadedList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final username = await TokenManager.getUsername(); // 假设这是你的方法
      courierController.text = username ?? '未知用户';
    } catch (e) {
      courierController.text = '未知用户';
    }
  }


  void submit() {
    if (scanController.text.isNotEmpty) {
      scannedList.add(scanController.text);
      scanController.clear();
    }
  }

  void upload() {
    if (scannedList.isNotEmpty) {
      uploadedList.addAll(scannedList);
      scannedList.clear();
    }
  }

  void onScanResult(String result) {
    scanController.text = result;
    submit();
  }

  @override
  void onClose() {
    scanController.dispose();
    super.onClose();
  }
}
