import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/http_client.dart';
import '../../http/api/token_manager.dart';

class OutboundScanController extends GetxController {
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
      final username = await ApiService().getUsername(); // 假设这是你的方法
      courierController.text = username ?? '未知用户';
    } catch (e) {
      courierController.text = '未知用户';
    }
  }


  @override
  void onClose() {
    scanController.dispose();
    super.onClose();
  }
}
