import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kimiflash/pages/delivery/detail/pending_delivery_detail_controller.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import '../../../http/api/auth_api.dart';
import '../models/delivery_item.dart';

class PendingDeliveryDetail extends StatefulWidget {
  final Map<String, dynamic> deliveryItem;

  const PendingDeliveryDetail({
    Key? key,
    required this.deliveryItem
  }) : super(key: key);

  @override
  State<PendingDeliveryDetail> createState() => _PendingDeliveryDetailPageState();
}

class _PendingDeliveryDetailPageState extends State<PendingDeliveryDetail> {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(PendingDeliveryDetailController());
  late Map<String, dynamic> deliveryDetails; // 用于存储请求返回的数据

  @override
  void initState() {
    super.initState();
    deliveryDetails = {}; // 初始化为空对象
    // 默认加载第一个 tab 的数据
    _fetchOrders(widget.deliveryItem['id']);
  }

  Future<void> _fetchOrders(int orderId) async {
    try {
      final response = await _authApi.DeliverManDeliveryDetail({
        "orderId": orderId,
        "customerCode": "10010"
      });

      if (response.code == 200) {
        setState(() {
          deliveryDetails = response.data; // 假设Response类有一个data字段包含详细数据
        });
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误', snackPosition: SnackPosition.BOTTOM); // 指定snackbar的位置
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString(), snackPosition: SnackPosition.BOTTOM); // 指定snackbar的位置
    } finally {
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配送详情'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: deliveryDetails.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '小货单号：${deliveryDetails['kySmallShipment'] ?? ''}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '姓名：${deliveryDetails['recipientName'] ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '电话：${deliveryDetails['recipientName'] ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '地址：${deliveryDetails['recipetenAddressFirst'] ?? ''}${deliveryDetails['recipetenAddressSecond'] ?? ''}${deliveryDetails['recipetenAddressThid'] ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '件数：${deliveryDetails['pcscount'] ?? 0}件',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '所属品类1: ${deliveryDetails['category1Items']?.length ?? 0}项',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '所属品类2: ${deliveryDetails['category2Items']?.length ?? 0}项',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

