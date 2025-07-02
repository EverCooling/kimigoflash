import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart'; // 新增依赖：用于图片预览

import '../../http/api/auth_api.dart'; // 导入dart.convert以使用json

class MultiImagePicker extends StatefulWidget {
  final int maxCount;
  final ValueChanged<List<AssetEntity>>? onChanged;
  final List<AssetEntity>? initialValue;
  final Function(List<String>) onImageUploaded;

  const MultiImagePicker({
    Key? key,
    this.maxCount = 9,
    this.onChanged,
    this.initialValue,
    required this.onImageUploaded,
  }) : super(key: key);

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<AssetEntity> _selectedAssets;
  List<String> _uploadedUrls = []; // 存储上传后的图片URL

  @override
  void initState() {
    super.initState();
    _selectedAssets = widget.initialValue ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择图片',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: _selectedAssets.length < widget.maxCount
              ? _selectedAssets.length + 1
              : _selectedAssets.length,
          itemBuilder: (context, index) {
            if (index < _selectedAssets.length) {
              final asset = _selectedAssets[index];
              return GestureDetector(
                onTap: () => _previewImage(index), // 点击图片预览
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: AssetEntityImage(
                        asset,
                        isOriginal: false,
                        fit: BoxFit.cover,
                        thumbnailFormat: ThumbnailFormat.jpeg,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeAsset(index),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.redGradient[400],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFEE5C5C)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Color(0xFFEE5C5C),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            '选择图片来源',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImagesFromGallery();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: const CameraPickerConfig(enableRecording: false),
    );

    if (entity != null) {
      setState(() {
        _selectedAssets.add(entity);
      });
      widget.onChanged?.call(_selectedAssets);
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: widget.maxCount,
        selectedAssets: _selectedAssets,
        requestType: RequestType.image,
        textDelegate: const EnglishAssetPickerTextDelegate(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAssets = result;
      });
      widget.onChanged?.call(_selectedAssets);
      await _uploadSelectedImages();
    }
  }

  void _removeAsset(int index) {
    setState(() {
      _selectedAssets.removeAt(index);
    });
    widget.onChanged?.call(_selectedAssets);
  }

  // 新增方法：预览图片
  Future<void> _previewImage(int index) async {
    final asset = _selectedAssets[index];
    final File? file = await asset.file;

    if (file == null) return;

    // 使用PhotoView进行图片预览
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              imageProvider: FileImage(file),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  // 上传选中的图片
  Future<void> _uploadSelectedImages() async {
    if (_selectedAssets.isEmpty) return;

    try {
      final List<String> uploadedUrls = [];
      HUD.show(context);
      for (var asset in _selectedAssets) {
        final File? file = await asset.file;
        if (file != null) {
          final response = await AuthApi().uploadFile(file);
          print("图片上传成功");
          print(response.data['value']);
          if(response.data != null) {
            uploadedUrls.add(response.data!['value']);
          }
        }
      }
      HUD.hide();
      setState(() {
        _uploadedUrls = uploadedUrls;
      });

      // 回调返回上传后的路径
      if (_uploadedUrls.isNotEmpty) {
        print(_uploadedUrls);
        widget.onImageUploaded(_uploadedUrls);
      }
      // 提示用户上传成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片上传成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片上传失败: $e')),
      );
    }
  }
}