import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SignReceiptScanController extends GetxController {
  final scanController = TextEditingController();

  // 表单字段
  final kyInStorageNumber = ''.obs;
  final selectedMethod = Rx<String?>(null);
  final uploadedImage = Rx<String?>(null);

  // 签名数据
  final points = <Offset?>[].obs;

  // 可选签收方式
  final List<String> methods = ['本人签收', '自提签收', '其他签收'];

  // 提交逻辑
  void submit() {
    if (kyInStorageNumber.value.isEmpty || selectedMethod.value == null) {
      Get.snackbar('错误', '请填写必要信息');
      return;
    }

    // TODO: 实现提交逻辑，如上传服务器或保存本地
    Get.snackbar('成功', '已提交签收信息');

    // 清空表单
    kyInStorageNumber.value = '';
    selectedMethod.value = null;
    uploadedImage.value = null;
    points.clear();
  }

  // 添加签名点
  void addPoint(Offset point) {
    points.add(point);
  }

  // 清除签名
  void clearSignature() {
    points.clear();
  }

  // 模拟图片上传
  void uploadImage() {
    // 这里调用图片选择器逻辑
    uploadedImage.value = '图片已上传'; // 模拟上传成功
  }
}
