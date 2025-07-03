import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:kimiflash/pages/completed_delivery/model/delivery_detail.dart';
import 'package:kimiflash/pages/delivery/detail/pending_delivery_detail_controller.dart';
import 'dart:convert'; // 确保导入了jsonEncode方法
import '../../../http/api/auth_api.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/loading_manager.dart';
import '../../widgets/multi_image_picker.dart';
import '../../widgets/sign_method_bottom_sheet.dart';
import '../../widgets/signature_preview.dart';

class PendingDeliveryDetail extends StatefulWidget {
  final Map<String, dynamic> deliveryItem;

  const PendingDeliveryDetail({Key? key, required this.deliveryItem})
    : super(key: key);

  @override
  State<PendingDeliveryDetail> createState() =>
      _PendingDeliveryDetailPageState();
}

class _PendingDeliveryDetailPageState extends State<PendingDeliveryDetail> {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(PendingDeliveryDetailController());
  DeliveryDetail? deliveryDetails;
  List<String>? _receiptImageUrls;
  String? _signatureImageUrl;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(widget.deliveryItem['id']);
    });
  }

  String getSignForTypeName(int signForType) {
    switch (signForType) {
      case 1:
        return '本人签收';
      case 2:
        return '家人代签';
      case 3:
        return '自提签收';
      default:
        return '未知签收类型';
    }
  }

  //本人签收返回1 自提签收返回2 其他签收返回3
  int _getSignMethodValue(String signMethod) {
    switch (signMethod) {
      case '本人签收':
        return 1;
      case '自提签收':
        return 2;
      case '其他签收':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _submit() async {
    print('提交按钮点击'); // 调试输出
    HUD.show(context);

    final form = _formKey.currentState;
    if (form?.saveAndValidate() ?? false) {
      try {
        // 获取表单值
        final Map<String, dynamic> formData = form!.value;
        final String? kyInStorageNumber = deliveryDetails?.kyInStorageNumber;
        final String signMethod = formData['signMethod'] ?? '';

        // 调用API提交数据
        final response = await _authApi.DeliveryManAddOrderDelivery({
          'kyInStorageNumber': kyInStorageNumber,
          'signForType': _getSignMethodValue(signMethod),
          'signForImg': json.encode(_receiptImageUrls), // 使用JSON字符串
          'signature': _signatureImageUrl ?? '',
          'customerCode': '10010'
        });
        if (response.code == 200) {

          Get.snackbar('成功', '签收成功');
        } else {
          Get.snackbar('失败', response.msg ?? '验证失败');
        }
      } catch (e) {
        Get.snackbar('错误', e.toString());
      } finally {
        HUD.hide();
      }
    }
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
          deliveryDetails = DeliveryDetail.fromJson(response.data);
        });
      } else {
        Get.snackbar(
          '加载失败',
          snackPosition: SnackPosition.BOTTOM,
          response.msg,
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
    final controller = Get.find<PendingDeliveryDetailController>();
    return Scaffold(
      appBar: AppBar(title: const Text('待派详情')),
      body: Column(
        children: [
          // 可滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey, // 确保_formKey正确绑定
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 单号展示(独占一栏)
                    _buildInfoCard(
                      title: '运单号',
                      content: deliveryDetails?.kyInStorageNumber,
                      icon: Icons.confirmation_number,
                    ),
                    const SizedBox(height: 16),

                    // 2. 收件人信息(各占一行)
                    _buildInfoCard(
                      title: '收件人信息',
                      children: [
                        _buildInfoRow(
                          '姓名',
                          deliveryDetails?.recipientName ?? '',                          Icons.person,
                        ),
                        _buildInfoRow(
                          '电话',
                          deliveryDetails?.recipietnMobile ?? '',
                          Icons.phone,
                        ),
                        _buildInfoRow(
                          '地址',
                          deliveryDetails?.recipetenAddressFirst ?? '',
                          Icons.location_on,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(title: '品类', children: [
                      _buildCategoryRow(
                        '品类1',
                        deliveryDetails?.deliveryCustomerOrderDetailViewList,
                      ),
                    ]),


                    // 3. 总件数
                    _buildInfoCard(
                      title: '总件数',
                      content: '${deliveryDetails?.pcsCount ?? '0'}件',
                      icon: Icons.format_list_numbered,
                    ),
                    const SizedBox(height: 16),

                    // 6. 签收方式
                    CustomDropdownField(
                      name: 'signMethod',
                      labelText: '签收方式',
                      items: controller.methods,
                      initialValue: controller.selectedMethod,
                      onTap: (context) async {
                        final result = await SignMethodBottomSheet.show(
                          context,
                          methods: controller.methods,
                          initialValue: controller.selectedMethod,
                        );
                        if (result != null) {
                          print('叭叭叭叭叭 ===== ${result['value']}');
                          return result['value'];
                        }
                        return null;
                      }, validator: (value) {
                        return value == null ? '请选择签收方式' : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. 签收图片
                    // 图片上传区域
                    SizedBox(height: 8),
                    MultiImagePicker(
                      maxCount: 6,
                      onImageUploaded: (imagePaths) {
                        _receiptImageUrls = imagePaths;
                        print('选中的图片: ${imagePaths}');
                      },
                    ),
                    SizedBox(height: 20),

                    // 8. 客户签字板
                    SignaturePreview(
                      onSignatureChanged: (url) {
                        _signatureImageUrl = url;
                        // controller.setSignature(signatureBytes);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // 固定底部按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState == null) {
                  Get.snackbar(
                    '错误',
                    '表单未正确初始化，请重试',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                final form = _formKey.currentState;
                if (form != null && form.saveAndValidate()) {
                  _submit();
                } else {
                  print('表单未准备好或验证失败');
                  // 可选：显示提示信息
                  Get.snackbar(
                    '提示',
                    '请检查表单内容是否完整正确',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text('提交签收'),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCategoryRow(String label, List<OrderItem>? items) {
    if (items == null || items.isEmpty) {
      return _buildDetailRow(label: label, value: '无', icon: Icons.category);
    }

    final List<Widget> categoryWidgets = items.map((item) {
      return _buildDetailRow(
        label: label,
        value: item.brandEnglishName,
        icon: Icons.category,
        quantity: item.pcs.toString(),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryWidgets,
    );
  }

  Widget _buildDetailRow({required String label, required String value, required IconData icon, String quantity = ''}) {
    return Container(
      decoration: BoxDecoration(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value, style: TextStyle(fontSize: 16)),
                    if (quantity.isNotEmpty) Text('数量：$quantity}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
