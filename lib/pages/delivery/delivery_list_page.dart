import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'delivery_list_controller.dart';

class DeliveryListPage extends StatefulWidget {
  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> with SingleTickerProviderStateMixin {

  final AuthApi _authApi = AuthApi();
  final controller = Get.put(DeliveryListController());
  bool _isLoading = false;
  List<dynamic> _pendingList = [];   // 待派件
  List<dynamic> _completedList = []; // 已派件
  List<dynamic> _failedList = [];    // 派件失败

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(0);
    });
  }

  Future<void> _fetchOrders(int status) async {
    HUD.show(context);
    try {
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": status,
        "customerCode": "10010"
      });

      if (response.code == 200) {
        switch (status) {
          case 0:
            setState(() => _pendingList = response.data ?? []);
            break;
          case 1:
            setState(() => _completedList = response.data ?? []);
            break;
          case 2:
            setState(() => _failedList = response.data ?? []);
            break;
        }
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString());
    } finally {
      HUD.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('派件列表'),
        bottom: TabBar(
          controller: controller.tabController,
          tabs: [
            Tab(text: '待派件'),
            Tab(text: '已派件'),
            Tab(text: '派件失败'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          // 待派件
          _buildOrderList(_pendingList),
          // 已派件
          _buildOrderList(_completedList),
          // 派件失败
          _buildOrderList(_failedList),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('暂无数据'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        print("打印Item ==== ");
        print(order);
        return DeliveryListItem(
            item: order,
            onTap: () => controller.navigateToDetail(order, 'pending')
        );
        // return ListTile(
        //   title: Text(order['orderNumber'] ?? '未知单号'),
        //   subtitle: Text(order['customerName'] ?? '未知客户'),
        // );
      },
    );
  }
}
