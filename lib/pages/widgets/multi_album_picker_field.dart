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
  List<String> _uploadedPaths = []; // 存储上传成功的图片路径


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
          final response = await AuthApi().uploadFile(file);
          print("图片上传成功");
          print(response.data['value']);
          if(response.data != null) {
            uploadedPaths.add(response.data!['value']);
          }
        }
      }

      setState(() {
        _isUploading = false;
        _uploadedPaths = uploadedPaths; // 更新已上传图片路径
      });

      // 回调返回上传后的路径
      if (uploadedPaths.isNotEmpty) {
        print(uploadedPaths);
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
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            // 已上传图片预览
            ..._uploadedPaths.map((file) {
              final index = _uploadedPaths.indexOf(file);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                 Container(
                   width: 80,
                   height: 80,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.grey, width: 1.0),
                   ),
                   child:  ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: Image.network(file, fit: BoxFit.cover),
                   ),
                 ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      onPressed: ()=> {
                        setState(() {
                          _uploadedPaths.removeAt(index);
                        })
                      },
                      icon: Icon(Icons.cancel, color: Colors.red),
                      padding: EdgeInsets.zero,
                      iconSize: 24,
                    ),
                  )
                ],
              );
            }).toList(),

            // 添加按钮
            if (_uploadedPaths.length < widget.maxSelection)
              InkWell(
                onTap: ()=> {
                _pickAndUploadImages()
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red,width: 1.0),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.redAccent),
                      Text('添加图片', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}