// complete_delivery_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'complete_delivery_detail_controller.dart'; // 新增的控制器

class CompleteDeliveryDetailPage extends GetView<CompleteDeliveryDetailController> {
  final Map<String, dynamic> deliveryItem;

  const CompleteDeliveryDetailPage({Key? key, required this.deliveryItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('已派送详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailRow('单号', deliveryItem['trackingNumber']),
          _buildDetailRow('平台', deliveryItem['orderSource']),
          _buildDetailRow('派送方式', deliveryItem['deliveryMethod']),
          _buildDetailRow('收件人姓名', deliveryItem['recipientName']),
          _buildDetailRow('收件人电话', deliveryItem['recipientPhone']),
          _buildDetailRow('收件人地址', deliveryItem['address']),
          _buildDetailRow('总件数', deliveryItem['totalPackages']),
          _buildCategoryRow(
            '所属品类1',
            (deliveryItem['category1'] is List)
                ? (deliveryItem['category1'] as List).cast<dynamic>()
                : [],
          ),
          _buildCategoryRow(
            '所属品类2',
            (deliveryItem['category2'] is List)
                ? (deliveryItem['category2'] as List).cast<dynamic>()
                : [],
          ),
          _buildDetailRow('签收方式', deliveryItem['signatureMethod']),
          const SizedBox(height: 16),
          const Text('签收图片', style: TextStyle(fontWeight: FontWeight.bold)),
          // _buildImageGrid(deliveryItem['signatureImages'] as List ?? []),
          const SizedBox(height: 16),
          const Text('客户签字', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildSignatureImage(deliveryItem['customerSignature']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? '无'),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String label, List<dynamic>? items) {
    final String displayText = (items ?? []).isNotEmpty
        ? items!.map((e) => e.toString()).join('、')
        : '无';
    return _buildDetailRow(label, displayText);
  }

  Widget _buildImageGrid(List<dynamic> images) {
    if (images.isEmpty) {
      return const Text('暂无图片');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final String imageUrl = images[index]?.toString() ?? '';
        return Image.network(imageUrl, fit: BoxFit.cover);
      },
    );
  }

  Widget _buildSignatureImage(dynamic signature) {
    final String url = signature?.toString() ?? '';
    if (url.isEmpty) {
      return const Text('暂无签字');
    }
    return Image.network(url, fit: BoxFit.contain);
  }
}
