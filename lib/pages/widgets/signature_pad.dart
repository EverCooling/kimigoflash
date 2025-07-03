import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../http/api/auth_api.dart';

/// 自定义签名板组件，基于 Syncfusion Flutter SignaturePad
class SyncfusionSignaturePadWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color strokeColor;
  final double minStrokeWidth;
  final double maxStrokeWidth;
  final Function(String)? onUploadSuccess;
  final VoidCallback? onCleared;
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

        const SizedBox(height: 16),

        // 操作按钮区域
        Visibility(
          visible: !_isSaving,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 清除按钮
              TextButton(
                onPressed: _clearSignature,
                child: const Text('清除'),
              ),

              const SizedBox(width: 16),

              // 保存按钮
              TextButton(
                onPressed: _saveSignature,
                child: const Text('保存'),
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
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/signature_temp.png');
        await tempFile.writeAsBytes(pngBytes);

        // 上传图片
        if (await _uploadImage(tempFile)) {
          if (mounted) {
            setState(() => _isSaving = false);
          }
          return tempFile.path;
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
        throw Exception('保存失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('操作出错', '$e');
        setState(() => _isSaving = false);
      }
      return '';
    }
  }

  /// 上传图片
  Future<bool> _uploadImage(File file) async {
    try {
      final response = await AuthApi().uploadFile(file);
      if (response.data != null) {
        final imageUrl = response.data['value'];
        if (mounted) {
          Get.snackbar('签名已成功上传', response.msg ?? '上传成功');
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