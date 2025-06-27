import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingManager {
  static bool _isLoading = false;

  static void showLoading({String message = '加载中...'}) {
    if (_isLoading) return;

    _isLoading = true;

    // 使用 Get.snackbar 展示 loading（轻量级）
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(minutes: 1), // 持续显示直到 hideLoading
      dismissDirection: DismissDirection.down,
      mainButton: TextButton(
        onPressed: () {
          hideLoading();
        },
        child: Text('取消', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static void hideLoading() {
    if (!_isLoading) return;

    _isLoading = false;
    Get.closeCurrentSnackbar(); // 关闭 loading 提示
  }


//***********全屏**************

  static OverlayEntry? _overlayEntry;

  static void showFullScreenLoading([String? message]) {
    if (_isLoading || _overlayEntry != null) return;

    _isLoading = true;

    final overlay = Overlay.of(Get.context!)!;
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(message ?? '加载中...'),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hideFullScreenLoading() {
    if (!_isLoading || _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isLoading = false;
  }

}


