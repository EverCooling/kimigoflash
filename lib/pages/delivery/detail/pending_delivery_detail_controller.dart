import 'dart:ui';
import 'package:get/get.dart';

class PendingDeliveryDetailController extends GetxController {
  // final Map<String, dynamic> deliveryItem;
  //
  // PendingDeliveryDetailController({required this.deliveryItem});

  String? selectedMethod;
  final List<String> methods = ['本人签收', '家人代签收', '自提签收'];
  final uploadedImage = ''.obs;

  final List<Offset?> points = [];

  void setSelectedMethod(String? value) {
    selectedMethod = value;
    update();
  }

  void uploadImage() {
    // TODO: 实际图片上传逻辑，这里仅模拟
    uploadedImage.value = '图片已上传';
  }

  void addPoint(Offset point) {
    points.add(point);
  }

  void clearPoints() {
    points.clear();
  }
}
