import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/pages/screens/mobile_scanner_advanced.dart';

import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_method_bottom_sheet.dart';
import 'outbound_scan_controller.dart'; // 引入控制器

class OutboundScanPage extends StatelessWidget {
  const OutboundScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OutboundScanController());

    return Scaffold(
      appBar: AppBar(title: Text('出仓扫描')),
      body: Column(
        children: [
          // 可滑动的内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownField(
                    name: 'signMethod',
                    labelText: '所属派件员',
                    items: controller.couriers,
                    initialValue: null,
                    onTap: (context) async {
                      return SignMethodBottomSheet.show(
                        context,
                        methods: controller.couriers,
                        initialValue: null,
                        title: '选择所属派件员',
                        titleStyle: TextStyle(fontSize: 20, color: Colors.blue),
                        selectedColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        additionalActions: [
                          Divider(),
                          ListTile(
                            title: Text('取消', style: TextStyle(color: Colors.grey)),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    name: 'trackingNumber',
                    labelText: '扫描单号',
                    hintText: '请输入运单号',
                    prefixIcon: Icons.vertical_distribute,
                    onSuffixPressed: () async {},
                    onSubmitted: (value) async {},
                  ),
                  SizedBox(height: 20),
                  Text('扫描记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('已扫描', style: TextStyle(fontWeight: FontWeight.bold)),
                                Divider(),
                                Obx(() => SizedBox(
                                  height: 400, // 固定高度
                                  child: ListView.builder(
                                    itemCount: controller.scannedList.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(title: Text(controller.scannedList[index]));
                                    },
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('已上传', style: TextStyle(fontWeight: FontWeight.bold)),
                                Divider(),
                                Obx(() => SizedBox(
                                  height: 400, // 固定高度
                                  child: ListView.builder(
                                    itemCount: controller.uploadedList.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(title: Text(controller.uploadedList[index]));
                                    },
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 固定底部按钮
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: controller.upload,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('提交'),
            ),
          ),
        ],
      ),
    );
  }
}
