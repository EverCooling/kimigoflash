// exception_report_controller.dart
import 'package:get/get.dart';

class ExceptionReportController extends GetxController {
  final trackingNumber = ''.obs;
  final description = ''.obs;
  final selectedReason = ''.obs;
  final selectedImage = ''.obs;

  final reasons = [
    '电话无人接听',
    '收件人不在家',
    '地址错误',
    '其他原因',
  ];

  void submit() {
    if (trackingNumber.value.trim().isEmpty || selectedReason.value.isEmpty) {
      Get.snackbar('提示', '请填写必要信息');
      return;
    }

    // TODO: 实现提交逻辑，如上传服务器或保存本地
    Get.snackbar('成功', '已提交异常登记');

    // 清空表单
    trackingNumber.value = '';
    description.value = '';
    selectedReason.value = '';
    selectedImage.value = '';
  }
}
