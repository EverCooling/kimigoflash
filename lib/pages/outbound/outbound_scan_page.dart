import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  final _formKey = GlobalKey<FormBuilderState>(); // 新增表单键

  @override
  void initState() {
    super.initState();
    // 初始化时设置派件员信息（假设从其他地方获取）
    controller.courierController.text = '张三'; // 示例值，实际应从登录信息或其他地方获取
  }

  Future<void> _verifyOrder(String orderNumber) async {
    // 表单验证
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证单号格式
    final isValid = RegExp(r'^(GR|UKG).+').hasMatch(orderNumber);
    if (!isValid) {
      Get.snackbar('错误', '单号格式有误，请以GR或UKG开头');
      return;
    }

    HUD.show(context);

    try {
      final response = await _authApi.DeliverManScanOutWarehouse({
        'kyInStorageNumber': orderNumber,
        'customerCode': '10010',
        "lang": "zh"
      });

      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
        await _deliveryManBatchOutWarehouse(orderNumber);

        // 扫描成功后添加到scannedList（响应式列表，计数自动更新）
        controller.scannedList.add(orderNumber);

        // 清空输入框
        controller.scanController.clear();
        _formKey.currentState!.reset(); // 重置表单状态
      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      HUD.hide();
    }
  }

  Future<void> _deliveryManBatchOutWarehouse(String orderNumber) async {
    // 验证订单号不为空
    if (orderNumber.isEmpty) {
      Get.snackbar('错误', '订单号不能为空');
      return;
    }

    HUD.show(context);
    try {
      final uploadResponse = await _authApi.DeliveryManBatchOutWarehouse({
        'kyInStorageNumberList': [orderNumber],
        "customerCode": "10010"
      });

      if (uploadResponse.code == 200) {
        Get.snackbar('上传成功', '单号已上传');

        // 上传成功后添加到uploadedList（响应式列表，计数自动更新）
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
              child: FormBuilder(
                key: _formKey,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '派件员信息不能为空';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      name: 'kyInStorageNumber',
                      enabled: true,
                      labelText: '扫描单号',
                      hintText: '请输入运单号（以GR或UKG开头）',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入或扫描订单号';
                        }
                        if (!RegExp(r'^(GR|UKG).+').hasMatch(value)) {
                          return '订单号需以GR或UKG开头';
                        }
                        return null;
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
                                    children: controller.scannedList.map((item) => ListTile(
                                      title: Text(item),
                                      minTileHeight: 10,
                                      contentPadding: EdgeInsets.all(0),
                                    )).toList(),
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
                                    children: controller.uploadedList.map((item) => ListTile(
                                      title: Text(item),
                                      minTileHeight: 10,
                                      contentPadding: EdgeInsets.all(0),
                                    )).toList(),
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
          ),

          // 固定底部提交按钮
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // 验证所有表单字段
                if (_formKey.currentState!.validate()) {
                  // 这里可以添加批量上传功能
                  if (controller.scannedList.isNotEmpty) {
                    _batchUpload();
                  } else {
                    Get.snackbar('提示', '没有可上传的订单号');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('批量上传'),
            ),
          ),
        ],
      ),
    );
  }

  // 批量上传功能
  Future<void> _batchUpload() async {
    if (controller.scannedList.isEmpty) {
      Get.snackbar('提示', '没有可上传的订单号');
      return;
    }

    HUD.show(context);
    try {
      final uploadResponse = await _authApi.DeliveryManBatchOutWarehouse({
        'kyInStorageNumberList': controller.scannedList,
        "customerCode": "10010"
      });

      if (uploadResponse.code == 200) {
        Get.snackbar('上传成功', '${controller.scannedList.length}个单号已上传');

        // 批量上传成功后更新两个列表
        controller.uploadedList.addAll(controller.scannedList);
        controller.scannedList.clear();
      } else {
        Get.snackbar('上传失败', uploadResponse.msg ?? '上传出错');
      }
    } catch (e) {
      Get.snackbar('上传异常', e.toString());
    } finally {
      HUD.hide();
    }
  }
}