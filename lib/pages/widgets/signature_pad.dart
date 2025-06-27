import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// 自定义签名板组件，基于 Syncfusion Flutter SignaturePad
class SyncfusionSignaturePadWidget extends StatefulWidget {
  /// 签名板背景颜色
  final Color backgroundColor;

  /// 签名笔触颜色
  final Color strokeColor;

  /// 最小笔触宽度
  final double minStrokeWidth;

  /// 最大笔触宽度
  final double maxStrokeWidth;

  /// 签名保存成功后的回调，返回签名图片的Uint8List数据
  final Function(Uint8List)? onSaved;

  /// 签名清除后的回调
  final VoidCallback? onCleared;

  /// 组件高度，默认为200.0
  final double height;

  const SyncfusionSignaturePadWidget({
    Key? key,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.minStrokeWidth = 1.0,
    this.maxStrokeWidth = 3.0,
    this.onSaved,
    this.onCleared,
    this.height = 200.0,
  }) : super(key: key);

  @override
  _SyncfusionSignaturePadWidgetState createState() => _SyncfusionSignaturePadWidgetState();
}

class _SyncfusionSignaturePadWidgetState extends State<SyncfusionSignaturePadWidget> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 签名板区域
        Expanded(
          child: SfSignaturePad(
            key: _signaturePadKey,
            strokeColor: widget.strokeColor,
            minimumStrokeWidth: widget.minStrokeWidth,
            maximumStrokeWidth: widget.maxStrokeWidth,
          ),
        ),

        const SizedBox(height: 36),

        // 操作按钮区域
        Visibility(
          visible: !_isSaving,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 清除按钮
              // 清除按钮
              TextButton(
                onPressed: _clearSignature,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  // 以下样式设置去除按钮的边框和背景
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Row(
                  children: const [
                    // Icon(Icons.delete, size: 18),
                    SizedBox(width: 6),
                    Text('清除'),
                  ],
                ),
              ),


              const SizedBox(width: 16),

              // 保存按钮
              TextButton(
                onPressed: _saveSignature,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  // 去除按钮的边框和背景
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Row(
                  children: const [
                    // Icon(Icons.save, size: 18),
                    SizedBox(width: 6),
                    Text('保存'),
                  ],
                ),
              ),

            ],
          ),
        ),

        // 保存中加载状态
        _isSaving
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(),
        )
            : const SizedBox.shrink(),
      ],
    );
  }

  /// 清除签名
  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    if (widget.onCleared != null) {
      widget.onCleared!();
    }
  }

  /// 保存签名
  Future<void> _saveSignature() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // 请求存储权限
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要存储权限才能保存签名'))
        );
        setState(() => _isSaving = false);
        return;
      }
    }


    try {
      // 获取签名图片
      final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
      final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();

        // 保存到相册
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
          name: 'signature_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('签名已成功保存到相册'))
          );

          // 回调返回签名数据
          if (widget.onSaved != null) {
            widget.onSaved!(pngBytes as Uint8List);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存失败，请重试'))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未获取到签名图片数据'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存签名出错: $e'))
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}