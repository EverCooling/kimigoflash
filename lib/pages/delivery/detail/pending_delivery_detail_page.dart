import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kimiflash/pages/delivery/detail/pending_delivery_detail_controller.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';

import '../../../http/api/auth_api.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/multi_album_picker_field.dart';
import '../../widgets/sign_method_bottom_sheet.dart';
import '../../widgets/signature_preview.dart';

class PendingDeliveryDetail extends StatefulWidget {
  final Map<String, dynamic> deliveryItem;

  const PendingDeliveryDetail({
    Key? key,
    required this.deliveryItem
  }) : super(key: key);

  @override
  State<PendingDeliveryDetail> createState() => _PendingDeliveryDetailPageState();
}

class _PendingDeliveryDetailPageState extends State<PendingDeliveryDetail> {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(PendingDeliveryDetailController());
  late Map<String, dynamic> deliveryDetails; // 用于存储请求返回的数据
  List<String>? _receiptImageUrls;
  String? _signatureImageUrl;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    deliveryDetails = {}; // 初始化为空对象
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


  Future<void> _submit() async {
    print('提交按钮点击'); // 调试输出
    HUD.show(context);
    try {
      // 调用API提交数据
      final response = await _authApi.DeliveryManAddOrderDelivery({
        'kyInStorageNumber': deliveryDetails['kySmallShipment'] ?? '',
        'signForType': '',
        'signForImg': _receiptImageUrls?.isNotEmpty == true ? _receiptImageUrls![0] : '',
        'signature': _signatureImageUrl ?? '',
        'customerCode':'10010'
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


  Future<void> _fetchOrders(int orderId) async {
    HUD.show(context); // 显示 HUD
    try {
      final response = await _authApi.DeliverManDeliveryDetail({
        "orderId": orderId,
        "customerCode": "10010"
      });

      if (response.code == 200) {

        setState(() {
          deliveryDetails = response.data; // 假设Response类有一个data字段包含详细数据
        });
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误', snackPosition: SnackPosition.BOTTOM); // 指定snackbar的位置
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString(), snackPosition: SnackPosition.BOTTOM); // 指定snackbar的位置
    } finally {
      HUD.hide();
    }
  }



  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PendingDeliveryDetailController>();
    final _formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(title: const Text('派送详情')),
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
                      content: deliveryDetails['kySmallShipment'] ?? '',
                      icon: Icons.confirmation_number,
                    ),
                    const SizedBox(height: 16),

                    // 2. 收件人信息(各占一行)
                    _buildInfoCard(
                      title: '收件人信息',
                      children: [
                        _buildInfoRow(
                            '姓名', deliveryDetails['recipientName'] ?? '',
                            Icons.person),
                        _buildInfoRow(
                            '电话', deliveryDetails['recipietnMobile'] ?? '',
                            Icons.phone),
                        _buildInfoRow(
                            '地址', deliveryDetails['recipetenAddressFirst'] ?? '',
                            Icons.location_on),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. 总件数
                    _buildInfoCard(
                      title: '总件数',
                      content: '${deliveryDetails['pcsCount'] ?? '0'}件',
                      icon: Icons.format_list_numbered,
                    ),
                    const SizedBox(height: 16),

                    // // 4. 所属品类1
                    // _buildCategorySection(
                    //     '所属品类1', deliveryDetails['category1Items'] ?? []),
                    // const SizedBox(height: 16),
                    //
                    // // 5. 所属品类2
                    // _buildCategorySection(
                    //     '所属品类2', deliveryDetails['category2Items'] ?? []),
                    // const SizedBox(height: 16),

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
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. 签收图片
                    // 图片上传区域
                    SizedBox(height: 8),
                    // 在页面中使用 MultiAlbumPickerField
                    MultiAlbumPickerField(
                      label: '上传签收图片',
                      maxSelection: 5,
                      onImageUploaded: (imagePaths) {
                        _receiptImageUrls = imagePaths;
                        // 处理上传后的图片路径列表
                        print('上传成功：$imagePaths');
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
                final form = _formKey.currentState;
                if (form != null && form.saveAndValidate()) {
                  _submit();
                } else {
                  print('表单未准备好或验证失败');
                  // 可选：显示提示信息
                  Get.snackbar('提示', '请检查表单内容是否完整正确', snackPosition: SnackPosition.BOTTOM);
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
//   Widget _buildCategorySection(String title, List<dynamic> items) {
//     return _buildInfoCard(
//       title: title,
//       children: [
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: items
//                 .map((item) => _buildCategoryItem(item.toString()))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }

// 构建单个品类项
//   Widget _buildCategoryItem(String itemName) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(Icons.circle, size: 8, color: Colors.grey),
//           const SizedBox(width: 8),
//           Text(itemName),
//         ],
//       ),
//     );
//   }
}
