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
  final _formKey = GlobalKey<FormBuilderState>();

  // 防止重复请求的标志
  final _isProcessing = false.obs;
  // 存储已处理的订单号集合（防止重复处理）
  final _processedOrders = <String>{}.obs;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _verifyOrder(String orderNumber) async {
    // 表单验证
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证单号格式
    if (!RegExp(r'^(GR|UKG).+').hasMatch(orderNumber)) {
      Get.snackbar('错误', '单号格式有误，请以GR或UKG开头');
      return;
    }

    // 检查是否正在处理中
    if (_isProcessing.value) {
      Get.snackbar('提示', '正在处理中，请稍候');
      return;
    }

    // 检查是否已处理过该订单
    if (_processedOrders.contains(orderNumber)) {
      Get.snackbar('提示', '该单号已处理过');
      return;
    }

    // 开始处理，设置标志
    _isProcessing.value = true;
    _processedOrders.add(orderNumber);
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
        controller.scannedList.add(orderNumber);
        controller.scanController.clear();
        _formKey.currentState!.reset();
      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
        // 验证失败，从已处理集合中移除
        _processedOrders.remove(orderNumber);
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
      _processedOrders.remove(orderNumber);
    } finally {
      // 处理完成，重置标志
      _isProcessing.value = false;
      HUD.hide();
    }
  }

  Future<void> _deliveryManBatchOutWarehouse(String orderNumber) async {
    // 验证订单号不为空
    if (orderNumber.isEmpty) {
      Get.snackbar('错误', '订单号不能为空');
      return;
    }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('出仓扫描')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      name: 'courier',
                      labelText: '所属派件员',
                      hintText: '',
                      controller: controller.courierController,
                      enabled: false,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value?.isEmpty ?? true ? '派件员信息不能为空' : null,
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
                      onSubmitted: (value) => value != null ? _verifyOrder(value) : null,
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
                                Obx(() => Column(
                                  children: controller.scannedList.map((item) => ListTile(
                                    title: Text(item),
                                    minTileHeight: 10,
                                    contentPadding: EdgeInsets.zero,
                                  )).toList(),
                                )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 400,
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Center(child: Text('已上传 (${controller.uploadedList.length})', style: TextStyle(fontWeight: FontWeight.bold))),
                                Divider(),
                                Obx(() => Column(
                                  children: controller.uploadedList.map((item) => ListTile(
                                    title: Text(item),
                                    minTileHeight: 10,
                                    contentPadding: EdgeInsets.zero,
                                  )).toList(),
                                )),
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

          // 底部按钮区域
          Obx(() => Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isProcessing.value || controller.scannedList.isEmpty
                  ? null
                  : _batchUpload,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isProcessing.value
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(width: 10),
                  Text('处理中...'),
                ],
              )
                  : Text('批量上传'),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _batchUpload() async {
    if (controller.scannedList.isEmpty) {
      Get.snackbar('提示', '没有可上传的订单号');
      return;
    }

    // 防止重复点击
    if (_isProcessing.value) return;
    _isProcessing.value = true;
    HUD.show(context);

    try {
      final uploadResponse = await _authApi.DeliveryManBatchOutWarehouse({
        'kyInStorageNumberList': controller.scannedList,
        "customerCode": "10010"
      });

      if (uploadResponse.code == 200) {
        Get.snackbar('上传成功', '${controller.scannedList.length}个单号已上传');
        controller.uploadedList.addAll(controller.scannedList);
        controller.scannedList.clear();
        _processedOrders.clear(); // 清空已处理集合
      } else {
        Get.snackbar('上传失败', uploadResponse.msg ?? '上传出错');
      }
    } catch (e) {
      Get.snackbar('上传异常', e.toString());
    } finally {
      _isProcessing.value = false;
      HUD.hide();
    }
  }
}