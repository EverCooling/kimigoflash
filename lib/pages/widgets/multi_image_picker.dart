import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_watermark/image_watermark.dart'; // 引入水印库
import 'package:location/location.dart'; // 引入定位库
import '../../http/api/auth_api.dart';

class MultiImagePicker extends StatefulWidget {
  final int maxCount;
  final ValueChanged<List<AssetEntity>>? onChanged;
  final List<AssetEntity>? initialValue;
  final Function(List<String>) onImageUploaded;
  final String? orderNumber; // 单号参数
  final double? watermarkX;    // 水印X坐标
  final double? watermarkY;    // 水印Y坐标
  final double? textSize;      // 水印文字大小
  final double? textPadding;   // 文字与背景的边距

  const MultiImagePicker({
    Key? key,
    this.maxCount = 9,
    this.onChanged,
    this.initialValue,
    required this.onImageUploaded,
    this.orderNumber,
    this.watermarkX = 50,
    this.watermarkY = 50,
    this.textSize = 16.0,     // 文字大小默认16
    this.textPadding = 8.0,    // 边距默认8
  }) : super(key: key);

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<AssetEntity> _selectedAssets;
  List<String> _uploadedUrls = [];
  List<String> _watermarkedPaths = []; // 存储带水印的图片路径
  LocationData? _locationData;
  bool _locationPermissionGranted = false;
  String? _previousOrderNumber; // 记录上一次的订单号

  @override
  void initState() {
    super.initState();
    _selectedAssets = widget.initialValue ?? [];
    _checkLocationPermission();
    _watermarkedPaths = List.filled(_selectedAssets.length, ''); // 初始化路径列表
    _previousOrderNumber = widget.orderNumber; // 初始化记录
  }

  @override
  void didUpdateWidget(covariant MultiImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当orderNumber参数变化时，重新处理已选择的图片
    if (widget.orderNumber != _previousOrderNumber && widget.orderNumber != null) {
      _reprocessImagesWithNewOrderNumber();
      _previousOrderNumber = widget.orderNumber;
    }
  }

  // 用新的订单号重新处理所有已选择的图片
  Future<void> _reprocessImagesWithNewOrderNumber() async {
    if (_selectedAssets.isEmpty || widget.orderNumber == null) return;

    setState(() {
      _watermarkedPaths = List.filled(_selectedAssets.length, ''); // 清空原有水印路径
    });

    await _uploadSelectedImages(); // 重新上传图片，生成新的水印
  }

  // 检查并请求位置权限
  Future<void> _checkLocationPermission() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      _locationData = await location.getLocation();
      _locationPermissionGranted = true;
    } catch (e) {
      print('获取位置失败: $e');
    }
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
              // 优先显示带水印的图片
              if (_watermarkedPaths[index].isNotEmpty) {
                return _buildWatermarkedImageTile(index);
              } else {
                return _buildOriginalImageTile(index);
              }
            } else {
              return _buildAddImageTile();
            }
          },
        ),
      ],
    );
  }

  // 构建带水印的图片卡片
  Widget _buildWatermarkedImageTile(int index) {
    return GestureDetector(
      onTap: () => _previewImage(index, isWatermarked: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.file(
              File(_watermarkedPaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported)),
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
  }

  // 构建原始图片卡片
  Widget _buildOriginalImageTile(int index) {
    return GestureDetector(
      onTap: () => _previewImage(index, isWatermarked: false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AssetEntityImage(
              _selectedAssets[index],
              isOriginal: false,
              fit: BoxFit.cover,
              thumbnailFormat: ThumbnailFormat.jpeg,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported)),
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
  }

  // 构建添加图片卡片
  Widget _buildAddImageTile() {
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
        _watermarkedPaths.add(''); // 新增图片时初始化空路径
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
        _watermarkedPaths = List.filled(_selectedAssets.length, ''); // 批量初始化路径
      });
      widget.onChanged?.call(_selectedAssets);
      await _uploadSelectedImages();
    }
  }

  void _removeAsset(int index) {
    setState(() {
      _selectedAssets.removeAt(index);
      _watermarkedPaths.removeAt(index);
    });
    widget.onChanged?.call(_selectedAssets);
  }

  Future<void> _previewImage(int index, {bool isWatermarked = false}) async {
    if (_selectedAssets.isEmpty) return;

    final List<File?> files = [];
    for (var i = 0; i < _selectedAssets.length; i++) {
      if (isWatermarked && _watermarkedPaths[i].isNotEmpty) {
        files.add(File(_watermarkedPaths[i]));
      } else {
        files.add(await _selectedAssets[i].file);
      }
    }

    final validFiles = files.where((file) => file != null).toList();
    if (validFiles.isEmpty) return;

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
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              itemCount: validFiles.length,
              builder: (context, i) {
                final file = validFiles[i];
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(file!),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                );
              },
              pageController: PageController(initialPage: index),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadSelectedImages() async {
    if (_selectedAssets.isEmpty || widget.orderNumber == null) return;

    try {
      final List<String> uploadedUrls = [];
      HUD.show(context);

      for (var i = 0; i < _selectedAssets.length; i++) {
        final asset = _selectedAssets[i];
        final file = await asset.file;
        if (file != null) {
          File? watermarkedFile;

          // 添加水印并保存路径
          watermarkedFile = await _addTextWatermarkToImage(file);
          if (watermarkedFile != null) {
            _watermarkedPaths[i] = watermarkedFile.path;
          }
          // 上传图片
          final response = await AuthApi().uploadFile(watermarkedFile ?? file);
          if (response.data != null) {
            uploadedUrls.add(response.data!['value']);
          }
        }
      }

      HUD.hide();
      setState(() {
        _uploadedUrls = uploadedUrls;
      });

      if (_uploadedUrls.isNotEmpty) {
        widget.onImageUploaded(_uploadedUrls);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片上传成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片上传失败: $e')),
      );
    }
  }

  Future<File> _addTextWatermarkToImage(File imageFile) async {
    try {
      final now = DateTime.now();
      final formattedTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      String watermarkText = '${widget.orderNumber}\n';

      if (_locationPermissionGranted && _locationData != null) {
        watermarkText += '${_locationData!.longitude.toString()}, ${_locationData!.latitude.toString()}\n';
      } else {
        watermarkText += '经纬度: 获取失败\n';
      }

      watermarkText += '$formattedTime';

      final Uint8List imgBytes = await imageFile.readAsBytes();

      // 黑底白字水印
      final watermarkedImg = await ImageWatermark.addTextWatermark(
        imgBytes: imgBytes,
        watermarkText: watermarkText,
        dstX: 100,
        dstY: 100,
        color: Colors.white,
      );

      // 保存带水印的图片
      final tempDir = await getTemporaryDirectory();
      final orderDir = widget.orderNumber != null
          ? '${tempDir.path}/${widget.orderNumber}'
          : tempDir.path;
      await Directory(orderDir).create(recursive: true);

      final tempFilePath = '$orderDir/${DateTime.now().millisecondsSinceEpoch}_watermark.jpg';
      final watermarkedFile = File(tempFilePath);
      await watermarkedFile.writeAsBytes(watermarkedImg);

      return watermarkedFile;
    } catch (e) {
      print('添加水印失败: $e');
      return imageFile;
    }
  }
}