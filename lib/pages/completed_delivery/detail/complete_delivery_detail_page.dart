// complete_delivery_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../../../http/api/auth_api.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/loading_manager.dart';
import 'complete_delivery_detail_controller.dart'; // 新增的控制器

class CompleteDeliveryDetailPage extends StatefulWidget {
  final Map<String, dynamic> deliveryItem;

  const CompleteDeliveryDetailPage({super.key, required this.deliveryItem});

  @override
  State<CompleteDeliveryDetailPage> createState() =>
      _CompleteDeliveryDetailPageState();
}

class _CompleteDeliveryDetailPageState extends State<CompleteDeliveryDetailPage> {
  final controller = Get.put(CompleteDeliveryDetailController());
  late Map<String, dynamic> deliveryDetails; // 用于存储请求返回的数据
  final AuthApi _authApi = AuthApi();

  @override
  void initState() {
    super.initState();
    deliveryDetails = {}; // 初始化为空对象
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(widget.deliveryItem['id']);
    });
  }


  Future<void> _fetchOrders(int orderId) async {
    HUD.show(context); // 显示 HUD
    try {
      final response = await _authApi.DeliverManDeliveryDetail({
        "orderId": orderId,
        "customerCode": "10010",
      });

      if (response.code == 200) {
        setState(() {
          deliveryDetails = response.data; // 假设Response类有一个data字段包含详细数据
        });
      } else {
        Get.snackbar(
          '加载失败',
          response.msg ?? '未知错误',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '网络错误',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      HUD.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('派送详情')),
      body: Column(
        children: [
          // 可滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 单号展示(独占一栏)
                  _buildInfoCard(
                    title: '运单号',
                    content: deliveryDetails['kyInStorageNumber'] ?? '',
                    icon: Icons.confirmation_number,
                  ),
                  const SizedBox(height: 16),

                  // 2. 收件人信息(各占一行)
                  _buildInfoCard(
                    title: '收件人信息',
                    children: [
                      _buildInfoRow(
                        '姓名',
                        deliveryDetails['recipientName'] ?? '',
                        Icons.person,
                      ),
                      _buildInfoRow(
                        '电话',
                        deliveryDetails['recipietnMobile'] ?? '',
                        Icons.phone,
                      ),
                      _buildInfoRow(
                        '地址',
                        deliveryDetails['recipetenAddressFirst'] ?? '',
                        Icons.location_on,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. 所属品类2
                  _buildCategoryRow(
                      '品类',
                      deliveryDetails['deliveryCustomerOrderDetailViewList'] ?? []
                  ),


                  // 3. 总件数
                  _buildInfoCard(
                    title: '总件数',
                    content: '${deliveryDetails['pcsCount'] ?? '0'}件',
                    icon: Icons.format_list_numbered,
                  ),
                  const SizedBox(height: 16),

                  // 6. 签收方式
                  _buildInfoCard(
                    title: '签收方式',
                    content: deliveryDetails['signForType'] ?? '',
                    icon: Icons.confirmation_number,
                  ),

                  SizedBox(height: 16),
                  _buildImageGrid(deliveryDetails['signForImg']),
                  // 8. 客户签字板
                  const SizedBox(height: 32),
                  _buildSignatureImage(deliveryDetails['signature']),
                ],
              ),
            ),
          ),
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

  // 构建信息卡片
  Widget _buildInfoCard({
    required String title,
    String? content,
    List<Widget>? children,
    IconData? icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      color: Colors.transparent,
      // 透明背景
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white, // 白色背景
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (content != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(content, style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
            if (children != null) ...[const SizedBox(height: 8), ...children],
          ],
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
                // const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
