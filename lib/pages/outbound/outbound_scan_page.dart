import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import '../../http/api/auth_api.dart';
import '../widgets/custom_text_field.dart';
import 'outbound_scan_controller.dart'; // 引入控制器

class OutboundScanPage extends StatefulWidget {
  const OutboundScanPage({Key? key}) : super(key: key);

  @override
  State<OutboundScanPage> createState() => _OutboundScanPageState();

}

class _OutboundScanPageState extends State<OutboundScanPage> {
  final controller = Get.put(OutboundScanController());
  final AuthApi _authApi = AuthApi();

  Future<void> _verifyOrder(String orderNumber) async {
    final isValid = RegExp(r'^(GR|UKG).+').hasMatch(orderNumber);
    if (!isValid) {
      Get.snackbar('错误', '单号有误，请重新操作');
      return;
    }
    HUD.show(context);

    try {
      final response = await _authApi.DeliverManScanOutWarehouse({
        'kyInStorageNumber': orderNumber,
        'customerCode': '10010',
        "lang":"zh"
      });
      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
        await _deliveryManBatchOutWarehouse(orderNumber);
        controller.scannedList.add(orderNumber);

      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      HUD.hide();
    }
  }


  Future<void>  _deliveryManBatchOutWarehouse(String orderNumber) async {
    // 新增：调用上传接口
    HUD.show(context);
    try {
      final uploadResponse = await _authApi.DeliveryManBatchOutWarehouse({
        'kyInStorageNumberList': [orderNumber],
        "customerCode": "10010"
      });

      if (uploadResponse.code == 200) {
        Get.snackbar('上传成功', '单号已上传');
        controller.uploadedList.add(orderNumber);
      } else {
        Get.snackbar('上传失败', uploadResponse.msg ?? '上传出错');
      }
    } catch (e) {
      Get.snackbar('上传异常', e.toString());
    } finally {
      HUD.hide();
    }
  }


  @override
  Widget build(BuildContext context) {
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
                  CustomTextField(
                    name: 'courier',
                    labelText: '所属派件员',
                    controller: controller.courierController,
                    enabled: false, // 禁用编辑
                    prefixIcon: Icons.person_outline,
                    hintText: '',
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    name: 'kyInStorageNumber',
                    labelText: '扫描单号',
                    hintText: '请输入运单号',
                    controller: controller.scanController,
                    prefixIcon: Icons.vertical_distribute,
                    suffixIcon: Icons.barcode_reader,
                    onSuffixPressed: () async {
                      final barcodeResult = await Get.toNamed('/scanner');
                      if (barcodeResult != null) {
                        await _verifyOrder(barcodeResult);
                      }
                    },
                    onSubmitted: (value) async {
                      if (value != null) await _verifyOrder(value);
                    },
                  ),
                  SizedBox(height: 20),
                  Text('扫描记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 400,
                          child: ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Center(child: Text('已扫描 (${controller.scannedList.length})', style: TextStyle(fontWeight: FontWeight.bold))),
                              Divider(),
                              Obx(() {
                                return Column(
                                  children: controller.scannedList.map((item) => ListTile(title: Text(item),minTileHeight: 10,contentPadding: EdgeInsets.all(0))).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 400,
                          child: ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Center(child: Text('已上传 (${controller.uploadedList.length})', style: TextStyle(fontWeight: FontWeight.bold))),
                              Divider(),
                              Obx(() {
                                return Column(
                                  children: controller.uploadedList.map((item) => ListTile(title: Text(item),minTileHeight: 10,contentPadding: EdgeInsets.all(0),)).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 固定底部按钮
          // Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: ElevatedButton(
          //     onPressed: controller.upload,
          //     style: ElevatedButton.styleFrom(
          //       minimumSize: Size(double.infinity, 50),
          //     ),
          //     child: Text('提交'),
          //   ),
          // ),
        ],
    )
    );
  }
}
