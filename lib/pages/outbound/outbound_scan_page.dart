import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/token_manager.dart';
import 'package:kimiflash/pages/screens/mobile_scanner_advanced.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../http/api/auth_api.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_method_bottom_sheet.dart';
import 'outbound_scan_controller.dart'; // 引入控制器

class OutboundScanPage extends StatefulWidget {
  const OutboundScanPage({Key? key}) : super(key: key);

  @override
  State<OutboundScanPage> createState() => _OutboundScanPageState();

}

class _OutboundScanPageState extends State<OutboundScanPage> {
  bool _isLoading = false;

  final AuthApi _authApi = AuthApi();

  Future<void> _verifyOrder(String orderNumber) async {
    setState(() => _isLoading = true);
    try {
      final response = await _authApi.DeliverManScanOutWarehouse({
        'kyInStorageNumber': orderNumber,
        'customerCode': '10010',
        "lang":"zh"
      });
      setState(() {
        _isLoading = false;
      });

      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OutboundScanController());
    final RegExp trackingNumberRegex = RegExp(r'^(GR|KG).+');
    bool isLoading = false;

    return LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: CircularProgressIndicator(),
        child: Scaffold(
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
                        name: 'trackingNumber',
                        labelText: '扫描单号',
                        hintText: '请输入运单号',
                        prefixIcon: Icons.vertical_distribute,
                        suffixIcon: Icons.barcode_reader,
                        onSuffixPressed: () async {
                          final barcodeResult = await Get.toNamed('/scanner');
                          if (barcodeResult != null) {
                            isLoading = true;
                            await _verifyOrder(barcodeResult);
                            isLoading = false;
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
        ));
  }
}
