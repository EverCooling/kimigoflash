import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart'; // 引入path_provider

import '../../http/api/auth_api.dart';

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

  /// 签名上传成功后的回调，返回图片URL
  final Function(String)? onUploadSuccess;

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
    this.onUploadSuccess,
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
              TextButton(
                onPressed: _clearSignature,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Row(
                  children: const [
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
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Row(
                  children: const [
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
  Future<String> _saveSignature() async {
    if (_isSaving || !mounted) return '';

    setState(() => _isSaving = true);

    try {
      // 获取签名图片
      final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
      final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          // 获取文件路径
          String? filePath = "";
          File? file;
          // 如果没有有效路径，手动创建一个临时文件
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/signature_temp.png');
          await tempFile.writeAsBytes(pngBytes);
          filePath = tempFile.path;

          file = File(filePath);

          // 确保文件存在
          if (await file.exists()) {
            // 上传图片
            if (await _uploadImage(file)) {
              if (mounted) {
                setState(() => _isSaving = false);
              }
              return filePath;
            } else {
              if (mounted) {
                setState(() => _isSaving = false);
              }
              throw Exception('签名上传失败');
            }
          } else {
            if (mounted) {
              setState(() => _isSaving = false);
            }
            throw Exception('文件不存在，请重试');
          }
        } else {
          if (mounted) {
            setState(() => _isSaving = false);
          }
          throw Exception('保存失败，请重试');
        }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
            '操作出错',
            '$e'
        );
        setState(() => _isSaving = false);
      }
      return '';
    }
  }

  /// 上传图片
  Future<bool> _uploadImage(File file) async {
    try {
      final response = await AuthApi().uploadFile(file);
      print("图片上传成功");
      print(response.data['value']);
      if (response.data != null) {
        final imageUrl = response.data['value'];
        // 上传成功处理
        if (mounted) {
          Get.snackbar(
              '签名已成功上传',
              response.msg,
          );

          // 调用上传成功回调
          if (widget.onUploadSuccess != null) {
            widget.onUploadSuccess!(imageUrl);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        Get.snackbar('上传签名出错', '$e');
      }
      return false;
    }
  }
}