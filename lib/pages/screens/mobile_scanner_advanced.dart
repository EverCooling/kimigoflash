// mobile_scanner_advanced.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kimiflash/barcodescan/widgets/buttons/analyze_image_button.dart';
import 'package:kimiflash/barcodescan/widgets/buttons/toggle_flashlight_button.dart';
import 'package:kimiflash/barcodescan/widgets/dialogs/barcode_format_dialog.dart';
import 'package:kimiflash/barcodescan/widgets/dialogs/box_fit_dialog.dart';
import 'package:kimiflash/barcodescan/widgets/dialogs/detection_speed_dialog.dart';
import 'package:kimiflash/barcodescan/widgets/dialogs/detection_timeout_dialog.dart';
import 'package:kimiflash/barcodescan/widgets/dialogs/resolution_dialog.dart';
import 'package:kimiflash/barcodescan/widgets/scanned_barcode_label.dart';
import 'package:kimiflash/barcodescan/widgets/scanner_error_widget.dart';
import 'package:vibration/vibration.dart';

import 'package:get/get.dart';
import '../screens/mobile_scanner_advanced_controller.dart';

enum _PopupMenuItems {
  cameraResolution,
  detectionSpeed,
  detectionTimeout,
  returnImage,
  invertImage,
  autoZoom,
  useBarcodeOverlay,
  boxFit,
  formats,
  scanWindow,
}

class MobileScannerAdvanced extends GetView<MobileScannerAdvancedController> {
  const MobileScannerAdvanced({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Rect scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
      width: 300,
      height: 600,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('高级扫码'),
        actions: [
          PopupMenuButton<_PopupMenuItems>(
            onSelected: (item) async {
              switch (item) {
                case _PopupMenuItems.cameraResolution:
                // 示例：打开分辨率设置对话框
                  break;
                case _PopupMenuItems.detectionSpeed:
                // 打开检测速度设置
                  break;
                case _PopupMenuItems.formats:
                  final result = await Get.dialog(BarcodeFormatDialog(
                    selectedFormats: controller.selectedFormats,
                  ));
                  if (result != null) {
                    controller.reinitializeController(formats: result);
                  }
                  break;
                case _PopupMenuItems.boxFit:
                  final result = await Get.dialog(BoxFitDialog(
                    selectedBoxFit: controller.boxFit,
                  ));
                  if (result != null) {
                    controller.reinitializeController(fit: result);
                  }
                  break;
                case _PopupMenuItems.useBarcodeOverlay:
                  controller.useBarcodeOverlay = !controller.useBarcodeOverlay;
                  break;
                case _PopupMenuItems.scanWindow:
                  controller.useScanWindow = !controller.useScanWindow;
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: _PopupMenuItems.formats, child: Text('格式')),
              PopupMenuItem(value: _PopupMenuItems.boxFit, child: Text('适配方式')),
              CheckedPopupMenuItem(
                value: _PopupMenuItems.useBarcodeOverlay,
                checked: controller.useBarcodeOverlay,
                child: Text('显示条码框'),
              ),
              CheckedPopupMenuItem(
                value: _PopupMenuItems.scanWindow,
                checked: controller.useScanWindow,
                child: Text('扫描窗口'),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.controller,
            onDetect: controller.handleBarcode,
            errorBuilder: (context, error) => ScannerErrorWidget(error: error),
            fit: controller.boxFit,
          ),
          if (controller.useBarcodeOverlay)
            BarcodeOverlay(controller: controller.controller, boxFit: controller.boxFit),
          if (controller.useScanWindow)
            ScanWindowOverlay(scanWindow: scanWindow, controller: controller.controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Column(
                children: [
                  Expanded(child: ScannedBarcodeLabel(barcodes: controller.controller.barcodes)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ToggleFlashlightButton(controller: controller.controller),
                      AnalyzeImageButton(controller: controller.controller),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
