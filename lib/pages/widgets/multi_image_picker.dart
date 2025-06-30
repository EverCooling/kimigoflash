import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class MultiImagePicker extends StatefulWidget {
  final int maxCount;
  final ValueChanged<List<AssetEntity>>? onChanged;
  final List<AssetEntity>? initialValue;

  const MultiImagePicker({
    Key? key,
    this.maxCount = 9,
    this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<AssetEntity> _selectedAssets;

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
              return Stack(
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
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
              );
            } else {
              return GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.grey,
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
    }
  }

  void _removeAsset(int index) {
    setState(() {
      _selectedAssets.removeAt(index);
    });
    widget.onChanged?.call(_selectedAssets);
  }
}
