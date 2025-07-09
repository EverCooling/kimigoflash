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
import '../../http/api/auth_api.dart';

class MultiImagePicker extends StatefulWidget {
  final int maxCount;
  final ValueChanged<List<AssetEntity>>? onChanged;
  final List<AssetEntity>? initialValue;
  final Function(List<String>) onImageUploaded;
  final String? orderNumber; // 单号参数
  final int? watermarkX;    // 水印X坐标
  final int? watermarkY;    // 水印Y坐标
  final double? textSize;      // 水印文字大小
  final double? textPadding;   // 文字与背景的边距
  final double? backgroundOpacity; // 背景透明度

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
    this.backgroundOpacity = 0.7, // 背景透明度默认0.7
  }) : super(key: key);

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<AssetEntity> _selectedAssets;
  List<String> _uploadedUrls = [];
  List<String> _watermarkedPaths = []; // 存储带水印的图片路径
  bool _isProcessing = false; // 处理中状态标识

  @override
  void initState() {
    super.initState();
    // 使用可增长的列表初始化
    _selectedAssets = widget.initialValue?.toList() ?? [];
    _watermarkedPaths = List.filled(_selectedAssets.length, '',growable: true);
    // _checkGooglePlayServicesAvailability();
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
              return _buildGridItem(index, asset);
            } else {
              return _buildAddImageTile();
            }
          },
        ),
      ],
    );
  }

  // 提取网格项构建方法，统一添加key
  Widget _buildGridItem(int index, AssetEntity asset) {
    // 优先显示带水印的图片
    if (index < _watermarkedPaths.length && _watermarkedPaths[index].isNotEmpty) {
      return _buildWatermarkedImageTile(index, asset);
    } else if (_isProcessing) {
      return _buildLoadingTile(asset); // 加载项也需要key
    } else {
      return _buildOriginalImageTile(index, asset);
    }
  }

  // 构建带水印的图片卡片
  Widget _buildWatermarkedImageTile(int index,AssetEntity asset) {
    return GestureDetector(
      key: ValueKey('watermark_${asset.id}'),//唯一key，前缀+资产id
      onTap: () => _previewImage(index, isWatermarked: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.file(
              File(_watermarkedPaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('图片加载失败: $error');
                return const Center(child: Icon(Icons.image_not_supported));
              },
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
  Widget _buildOriginalImageTile(int index,AssetEntity asset) {
    return GestureDetector(
      key: ValueKey('original_${asset.id}'),//唯一key
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
              errorBuilder: (context, error, stackTrace) {
                print('原始图片加载失败: $error');
                return const Center(child: Icon(Icons.image_not_supported));
              },
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

  // 构建加载状态卡片
  Widget _buildLoadingTile(AssetEntity asset) {
    return Center(
      key: ValueKey('loading_${asset.id}'),//唯一key
      child: CircularProgressIndicator(
        color: AppColors.redGradient[400],
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
    try {
      final entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(enableRecording: false),
      );

      if (entity == null) {
        print('拍照返回的entity为null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('拍照失败，请重试')),
        );
        return;
      }

      setState(() {
        _selectedAssets.add(entity);
        _watermarkedPaths.add(''); // 新增图片时初始化空路径
        _isProcessing = true; // 标记为处理中
      });

      widget.onChanged?.call(_selectedAssets);

      // 处理图片（添加水印和上传）
      await _processSelectedImages();

    } catch (e) {
      print('拍照过程出错: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍照异常: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false; // 处理完成
      });
    }
  }

  // 修复相册选择逻辑：使用addAll而非替换列表
  Future<void> _pickImagesFromGallery() async {
    try {
      final result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: widget.maxCount - _selectedAssets.length,
          selectedAssets: [],
          requestType: RequestType.image,
          textDelegate: const EnglishAssetPickerTextDelegate(),
        ),
      );

      if (result == null || result.isEmpty) return;

      setState(() {
        // 关键：使用addAll添加新项，而非替换整个列表，保留旧项引用
        _selectedAssets.addAll(result);
        // 为新项初始化水印路径（只添加新项的空路径）
        _watermarkedPaths.addAll(List.filled(result.length, ''));
        _isProcessing = true;
      });

      widget.onChanged?.call(_selectedAssets);
      await _processSelectedImages();

    } catch (e) {
      // 错误处理不变
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 统一处理选中的图片（添加水印和上传）
  Future<void> _processSelectedImages() async {
    if (_selectedAssets.isEmpty) return;

    // 显示加载状态
    if (mounted) {
      HUD.show(context);
    }

    try {
      final List<String> uploadedUrls = [];

      for (var i = 0; i < _selectedAssets.length; i++) {
        final asset = _selectedAssets[i];
        final file = await asset.file;

        if (file == null) {
          print('图片文件为null，索引: $i');
          continue;
        }

        File? watermarkedFile;

        // 当orderNumber存在时添加水印，否则直接使用原图
        watermarkedFile = await _addTextWatermarkToImage(file);
        _watermarkedPaths[i] = watermarkedFile.path;


        // 上传图片
        final response = await AuthApi().uploadFile(watermarkedFile ?? file);
        if (response.data != null) {
          uploadedUrls.add(response.data!['value']);
        }
      }

      // 更新状态
      if (mounted) {
        setState(() {
          _uploadedUrls = uploadedUrls;
        });

        if (_uploadedUrls.isNotEmpty) {
          widget.onImageUploaded(_uploadedUrls);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片处理完成')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片处理失败: $e')),
        );
      }
      print('图片处理异常: $e');
    } finally {
      if (mounted) {
        HUD.hide();
      }
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

  Future<File> _addTextWatermarkToImage(File imageFile) async {
    try {
      // 格式化日期
      final now = DateTime.now();
      final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      // 构建水印文本（订单号、经纬度、日期时间）
      String watermarkText = '${widget.orderNumber}\n';


      watermarkText += '$formattedDate\n';
      watermarkText += '$formattedTime';

      final Uint8List imgBytes = await imageFile.readAsBytes();

      // 添加带黑色半透明背景的白色文字水印
      final watermarkedImg = await ImageWatermark.addTextWatermark(
        imgBytes: imgBytes,
        watermarkText: watermarkText,
        dstX: widget.watermarkX!,
        dstY: widget.watermarkY!,
        color: Colors.white,
      );

      // 保存带水印的图片
      final tempDir = await getTemporaryDirectory();
      final orderDir = widget.orderNumber != null
          ? '${tempDir.path}/${widget.orderNumber}'
          : '${tempDir.path}/no_order_watermark';
      await Directory(orderDir).create(recursive: true);

      final tempFilePath = '$orderDir/${now.millisecondsSinceEpoch}_watermark.jpg';
      final watermarkedFile = File(tempFilePath);
      await watermarkedFile.writeAsBytes(watermarkedImg);

      return watermarkedFile;
    } catch (e) {
      print('添加水印失败: $e');
      return imageFile;
    }
  }
}