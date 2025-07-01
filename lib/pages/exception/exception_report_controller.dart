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

}
