// mobile_scanner_advanced_controller.dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerAdvancedController extends GetxController {
  late MobileScannerController controller;

  Barcode? barcode;

  bool useScanWindow = false;
  bool autoZoom = false;
  bool invertImage = false;
  bool returnImage = false;

  Size desiredCameraResolution = const Size(1920, 1080);
  DetectionSpeed detectionSpeed = DetectionSpeed.unrestricted;
  int detectionTimeoutMs = 1000;

  bool useBarcodeOverlay = false;
  BoxFit boxFit = BoxFit.cover;

  List<BarcodeFormat> selectedFormats = [];

  @override
  void onInit() {
    super.onInit();
    controller = MobileScannerController(
      autoStart: false,
      cameraResolution: desiredCameraResolution,
      detectionSpeed: detectionSpeed,
      detectionTimeoutMs: detectionTimeoutMs,
      formats: selectedFormats,
      returnImage: returnImage,
      invertImage: invertImage,
      autoZoom: autoZoom,
    );
    unawaited(controller.start());
  }

  Future<void> reinitializeController({
    Size? resolution,
    DetectionSpeed? speed,
    int? timeout,
    BoxFit? fit,
    List<BarcodeFormat>? formats,
    bool? zoom,
    bool? image,
    bool? overlay,
    bool? scanWindow,
  }) async {
    await controller.dispose();
    controller = MobileScannerController(
      autoStart: false,
      cameraResolution: resolution ?? desiredCameraResolution,
      detectionSpeed: speed ?? detectionSpeed,
      detectionTimeoutMs: timeout ?? detectionTimeoutMs,
      formats: formats ?? selectedFormats,
      returnImage: image ?? returnImage,
      invertImage: zoom ?? invertImage,
      autoZoom: zoom ?? autoZoom,
    );
    await controller.start();
  }

  void handleBarcode(BarcodeCapture barcodes) {
    if (barcode != null) return;
    if (barcodes.barcodes.isEmpty) return;

    final bc = barcodes.barcodes.first;
    barcode = bc;
    update();

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.back(result: barcode?.rawValue);
    });

  }

  @override
  void onClose() {
    controller.dispose(); // ✅ 确保释放 MobileScannerController
    super.onClose();
  }

}
