import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OutboundScanController extends GetxController {
  // 使用 Rx<String?> 来确保 Obx 可以监听变化
  var selectedCourier = Rx<String?>(null);
  final List<String> couriers = ['张三', '李四', '王五'];

  final scanController = TextEditingController();

  // 使用 RxList 替代普通 List
  final scannedList = <String>[].obs;
  final uploadedList = <String>[].obs;

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
