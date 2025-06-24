import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'components/delivery_list_item.dart';
import 'delivery_list_controller.dart';

class DeliveryListPage extends GetView<DeliveryListController> {
  const DeliveryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('派送列表'),
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
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
          Obx(() => ListView.builder(
            itemCount: controller.pendingList.length,
            itemBuilder: (context, index) {
              final item = controller.pendingList[index];
              return DeliveryListItem(
                item: item,
                onTap: () => controller.navigateToDetail(item, 'pending'),
              );
            },
          )),

          // 已派件
          Obx(() => ListView.builder(
            itemCount: controller.completedList.length,
            itemBuilder: (context, index) {
              final item = controller.completedList[index];
              return DeliveryListItem(
                item: item,
                onTap: () => controller.navigateToDetail(item, 'completed'),
              );
            },
          )),

          // 派件失败
          Obx(() => ListView.builder(
            itemCount: controller.failedList.length,
            itemBuilder: (context, index) {
              final item = controller.failedList[index];
              return DeliveryListItem(
                  item: item,
                  onTap: () => controller.navigateToDetail(item, 'failed'),
              );
            },
          )),
        ],
      ),
    );
  }
}
