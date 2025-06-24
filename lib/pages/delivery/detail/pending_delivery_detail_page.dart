import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kimiflash/pages/delivery/detail/pending_delivery_detail_controller.dart';

import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/multi_image_picker_field.dart';
import '../../widgets/sign_method_bottom_sheet.dart';
import '../../widgets/signature_preview.dart';

class PendingDeliveryDetailPage extends StatelessWidget {
  final Map<String, dynamic> deliveryItem;

  const PendingDeliveryDetailPage({Key? key, required this.deliveryItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PendingDeliveryDetailController>();
    final _formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(title: const Text('签收详情')),
      body: Column(
        children: [
          // 可滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 单号展示(独占一栏)
                    _buildInfoCard(
                      title: '运单号',
                      content: deliveryItem['trackingNumber'] ?? '',
                      icon: Icons.confirmation_number,
                    ),
                    const SizedBox(height: 16),

                    // 2. 收件人信息(各占一行)
                    _buildInfoCard(
                      title: '收件人信息',
                      children: [
                        _buildInfoRow(
                            '姓名', deliveryItem['receiverName'] ?? '',
                            Icons.person),
                        _buildInfoRow(
                            '电话', deliveryItem['receiverPhone'] ?? '',
                            Icons.phone),
                        _buildInfoRow(
                            '地址', deliveryItem['receiverAddress'] ?? '',
                            Icons.location_on),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. 总件数
                    _buildInfoCard(
                      title: '总件数',
                      content: '${deliveryItem['totalQuantity'] ?? '0'}件',
                      icon: Icons.format_list_numbered,
                    ),
                    const SizedBox(height: 16),

                    // 4. 所属品类1
                    _buildCategorySection(
                        '所属品类1', deliveryItem['category1Items'] ?? []),
                    const SizedBox(height: 16),

                    // 5. 所属品类2
                    _buildCategorySection(
                        '所属品类2', deliveryItem['category2Items'] ?? []),
                    const SizedBox(height: 16),

                    // 6. 签收方式
                    CustomDropdownField(
                      name: 'signMethod',
                      labelText: '签收方式',
                      items: controller.methods,
                      initialValue: controller.selectedMethod,
                      onTap: (context) =>
                          SignMethodBottomSheet.show(
                            context,
                            methods: controller.methods,
                            initialValue: controller.selectedMethod,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // 7. 签收图片
                    Text('签收图片', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    MultiImagePickerField(
                      label: '',
                      maxImages: 5,
                      onImagesSelected: (images) {
                        // controller.setImages(images);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 8. 客户签字板
                    SignaturePreview(
                      onSignatureChanged: (signatureBytes) {
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
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  // controller.submitForm(_formKey.currentState!.value);
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
  Widget _buildInfoCard({required String title, String? content, List<
      Widget>? children, IconData? icon}) {
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
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (content != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                      child: Text(content, style: TextStyle(fontSize: 16),)),
                ],
              ),
            ],
            if (children != null) ...[
              const SizedBox(height: 8),
              ...children,
            ],
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
                  Text(label,
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  // const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          ]),
    );
  }

// 构建品类区域
  Widget _buildCategorySection(String title, List<dynamic> items) {
    return _buildInfoCard(
      title: title,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => _buildCategoryItem(item.toString()))
                .toList(),
          ),
        ),
      ],
    );
  }

// 构建单个品类项
  Widget _buildCategoryItem(String itemName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 8),
          Text(itemName),
        ],
      ),
    );
  }
}
