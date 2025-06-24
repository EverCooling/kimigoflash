// lib/widgets/multi_album_picker_field.dart
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';

import '../../http/api/auth_api.dart';

class MultiAlbumPickerField extends StatefulWidget {
  final String label;
  final int maxSelection;
  final Function(List<String>) onImageUploaded;

  const MultiAlbumPickerField({
    Key? key,
    required this.label,
    this.maxSelection = 5,
    required this.onImageUploaded,
  }) : super(key: key);

  @override
  State<MultiAlbumPickerField> createState() => _MultiAlbumPickerFieldState();
}

class _MultiAlbumPickerFieldState extends State<MultiAlbumPickerField> {
  List<AssetEntity> _selectedAssets = [];
  bool _isUploading = false;

  Future<void> _pickAndUploadImages() async {
    // 添加上下文检查
    if (context == null || !mounted) return;

    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          selectedAssets: _selectedAssets,
          maxAssets: widget.maxSelection,
          requestType: RequestType.image,
        ),

      );

      if (result == null || result.isEmpty) return;

      setState(() {
        _isUploading = true;
        _selectedAssets = result;
      });

      // 上传图片并获取返回路径
      final List<String> uploadedPaths = [];

      for (var asset in result) {
        final File? file = await asset.file;
        if (file != null) {
          final response = await AuthApi().uploadImage(file.path);
          if (response.success && response.data?['value'] is String) {
            uploadedPaths.add(response.data!['value']);
          }
        }
      }

      setState(() {
        _isUploading = false;
      });

      // 回调返回上传后的路径
      if (uploadedPaths.isNotEmpty) {
        widget.onImageUploaded(uploadedPaths);
      }
    } catch (e, stackTrace) {
      // 添加详细的错误日志
      debugPrint('图片选择异常: $e');
      debugPrint('异常堆栈: $stackTrace');
      
      // 防止在组件已销毁后调用setState
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
      
      // 显示错误提示
      Get.snackbar('图片选择失败', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: _pickAndUploadImages,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red,width: 1.0),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: _isUploading 
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.redAccent),
                    Text('添加图片', style: TextStyle(color: Colors.grey)),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}