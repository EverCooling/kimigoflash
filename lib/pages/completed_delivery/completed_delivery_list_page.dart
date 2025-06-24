// lib/pages/completed_delivery/completed_delivery_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'completed_delivery_list_controller.dart';

class CompletedDeliveryListPage extends GetView<CompletedDeliveryListController> {
  const CompletedDeliveryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('已派送列表')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索区域
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // 日期选择
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('选择日期'),
                        ElevatedButton.icon(
                          onPressed: () => controller.selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(controller.selectedDate ?? '请选择日期'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 派送方式 下拉选择
                    Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedMethod.value,
                      items: controller.deliveryMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedMethod(value ?? '');
                        controller.filterItems();
                      },
                      decoration: const InputDecoration(labelText: '派送方式'),
                    )),

                    const SizedBox(height: 16),

                    // 单号输入框
                    TextFormField(
                      onChanged: controller.trackingNumber,
                      decoration: const InputDecoration(labelText: '单号'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 列表部分
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.filteredItems.length,
                itemBuilder: (context, index) {
                  var item = controller.filteredItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('单号：${item['trackingNumber']}'),
                          const SizedBox(height: 4),
                          Text('收件人：${item['recipientName']}'),
                          const SizedBox(height: 4),
                          Text('地址：${item['address']}'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.navigation),
                            onPressed: () {
                              // TODO: 跳转地图导航
                              Get.snackbar("提示", "导航中...");
                            },
                            tooltip: '导航',
                          ),
                          IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () {
                              Get.snackbar("提示", "拨打客户电话");
                            },
                            tooltip: '拨打电话',
                          ),
                          if (item['signed'] == false)
                            ElevatedButton(
                              onPressed: () {
                                controller.markAsSigned(item);
                                Get.snackbar("成功", "签收成功");
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                              child: Text('签收'),
                            ),
                          ElevatedButton(
                            onPressed: () =>
                                controller.navigateToExceptionReport(item['trackingNumber']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text('失败', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
