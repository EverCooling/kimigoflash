import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kimiflash/pages/widgets/square_loading.dart';
import 'package:kimiflash/theme/app_colors.dart';

class HUD {
  static HUD? _instance;
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  factory HUD() {
    _instance ??= HUD._internal();
    return _instance!;
  }

  HUD._internal();

  // 显示 HUD
  static void show(BuildContext context, {String message = "加载中..."}) {
    if (_isShowing) return;

    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.redGradient[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 替换为正方形动画
                Container(
                  width: 40,
                  height: 40,
                  child: SquareLoading(),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // 隐藏 HUD
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}