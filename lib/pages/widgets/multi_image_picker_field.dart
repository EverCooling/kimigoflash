import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MultiImagePickerField extends StatefulWidget {
  final String label;
  final int maxImages;
  final Function(List<File>) onImagesSelected;

  const MultiImagePickerField({
    Key? key,
    required this.label,
    this.maxImages = 5,
    required this.onImagesSelected,
  }) : super(key: key);

  @override
  State<MultiImagePickerField> createState() => _MultiImagePickerFieldState();
}

class _MultiImagePickerFieldState extends State<MultiImagePickerField> {
  List<File> _imageFiles = [];

  final ImagePicker _picker = ImagePicker();

  // 修改 _pickImage 方法
  Future<void> _pickImage() async {
    if (_imageFiles.length >= widget.maxImages) {
      _showSnackBar('最多只能上传 ${widget.maxImages} 张图片');
      return;
    }

    final pickedOption = await _showPickOptionsDialog(context);
    if (pickedOption == null) return;

    try {
      final List<XFile> images = pickedOption == 'camera'
          ? [?await _picker.pickImage(source: ImageSource.camera)]
          : await _picker.pickMultiImage(limit: widget.maxImages - _imageFiles.length,
      );

      if (images.isNotEmpty) {
        final List<File> newFiles = images
            .where((image) => image != null)
            .map((image) => File(image.path))
            .toList();

        setState(() {
          _imageFiles.addAll(newFiles);
        });
        widget.onImagesSelected(_imageFiles);
      }
    } catch (e) {
      _showSnackBar('选择图片失败: ${e.toString()}');
    }
  }

// 修改 _showPickOptionsDialog 方法增加批量选择提示
  Future<String?> _showPickOptionsDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择图片'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('拍照'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('从相册选择(可多选)'),
                subtitle: Text('最多可选${widget.maxImages}张'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
    widget.onImagesSelected(_imageFiles);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            ..._imageFiles.map((file) {
              final index = _imageFiles.indexOf(file);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      onPressed: () => _removeImage(index),
                      icon: Icon(Icons.cancel, color: Colors.red),
                      padding: EdgeInsets.zero,
                      iconSize: 24,
                    ),
                  )
                ],
              );
            }).toList(),

            // 添加按钮
            if (_imageFiles.length < widget.maxImages)
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
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
