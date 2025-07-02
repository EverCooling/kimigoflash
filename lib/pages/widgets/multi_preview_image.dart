import 'package:flutter/material.dart';

/// 图片预览组件 - 支持单图和多图预览
class ImagePreviewWidget extends StatelessWidget {
  final List<String> imageUrls;       // 图片URL列表
  final int initialIndex;             // 初始显示的图片索引
  final String? title;                // 预览标题
  final bool showAppBar;              // 是否显示AppBar

  const ImagePreviewWidget({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.title,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: showAppBar ? _buildAppBar() : null,
      body: _buildPreviewBody(),
    );
  }

  // 构建AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.7),
      title: Text(title ?? '图片预览'),
      centerTitle: true,
    );
  }

  // 构建预览主体
  Widget _buildPreviewBody() {
    return PageView.builder(
      itemCount: imageUrls.length,
      controller: PageController(initialPage: initialIndex),
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildImageViewer(imageUrls[index]);
      },
    );
  }

  // 构建图片查看器
  Widget _buildImageViewer(String imageUrl) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true,
        child: Hero(
          tag: imageUrl,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 显示单张图片预览
void showSingleImagePreview(BuildContext context,String imageUrl, {String? title}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImagePreviewWidget(
        imageUrls: [imageUrl],
        title: title ?? '图片预览',
      ),
    ),
  );
}

/// 显示多张图片预览
void showMultipleImagePreview(
    BuildContext context,
    List<String> imageUrls, {
      int initialIndex = 0,
      String? title,
    }) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImagePreviewWidget(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        title: title ?? '图片预览',
      ),
    ),
  );
}