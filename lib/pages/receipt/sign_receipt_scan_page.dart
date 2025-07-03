import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kimiflash/pages/receipt/sign_receipt_scan_controller.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/pages/widgets/signature_preview.dart';
import '../../http/api/auth_api.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multi_image_picker.dart';
import '../widgets/sign_method_bottom_sheet.dart';

class SignReceiptScanPage extends StatefulWidget {
  const SignReceiptScanPage({Key? key}) : super(key: key);

  @override
  State<SignReceiptScanPage> createState() => _SignReceiptScanPageState();
}

class _SignReceiptScanPageState extends State<SignReceiptScanPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final controller = Get.put(SignReceiptScanController());
  String? _uploadedImage;
  final ImagePicker _picker = ImagePicker();
  String _statusMessage = '请在下方签名';
  List<String>? _receiptImageUrls;
  String? _signatureImageUrl;

  final AuthApi _authApi = AuthApi();

  Future<void> _verifyOrder(String orderNumber) async {
    HUD.show(context);
    try {
      final response = await _authApi.CheckOrderIsDeliver({
        "kyInStorageNumber": orderNumber,
        "customerCode": "10010",
        "lang": "zh"
      });
      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      HUD.hide();
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

    final form = _formKey.currentState;
    if (form?.saveAndValidate() ?? false) {
      try {
        // 获取表单值
        final Map<String, dynamic> formData = form!.value;
        // 从表单中获取订单号（注意：这里使用正确的表单字段名）
        final String kyInStorageNumber = formData['trackingNumber'] ?? '';
        final String signMethod = formData['signMethod'] ?? '';

        // 验证订单号是否存在
        if (kyInStorageNumber.isEmpty) {
          Get.snackbar('错误', '请输入或扫描订单号');
          return;
        }

        print('提交的订单号: $kyInStorageNumber'); // 调试输出

        HUD.show(context);
        // 调用API提交数据
        final response = await _authApi.DeliveryManAddOrderDelivery({
          'kyInStorageNumber': kyInStorageNumber,
          'signForType': _getSignMethodValue(signMethod),
          'signForImg': _receiptImageUrls?.isNotEmpty == true ? _receiptImageUrls![0] : '',
          'signature': _signatureImageUrl ?? '',
          'customerCode':'10010'
        });

        if (response.code == 200) {
          Get.snackbar('成功', '签收成功');
          // 签收成功后可以返回上一页
          Navigator.of(context).pop();
        } else {
          Get.snackbar('失败', response.msg ?? '验证失败');
        }
      } catch (e) {
        Get.snackbar('错误', e.toString());
      } finally {
        HUD.hide();
      }
    } else {
      print('表单验证失败');
      // 显示验证错误信息
      Get.snackbar('错误', '请检查表单输入');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('签收扫描')),
      body: Column(
        children: [
          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              physics: AlwaysScrollableScrollPhysics(),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    CustomTextField(
                      name: 'trackingNumber',
                      labelText: '扫描单号',
                      enabled: true,
                      hintText: '请输入运单号',
                      prefixIcon: Icons.vertical_distribute,
                      suffixIcon: Icons.barcode_reader,
                      onSuffixPressed: () async {
                        final barcodeResult = await Get.toNamed('/scanner');
                        if (barcodeResult != null) {
                          _formKey.currentState?.fields['trackingNumber']?.didChange(barcodeResult);
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
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    CustomDropdownField(
                      name: 'signMethod',
                      labelText: '签收方式',
                      items: controller.methods,
                      initialValue: null,
                      onTap: (context) async {
                        final result = await SignMethodBottomSheet.show(
                          context,
                          methods: controller.methods,
                          initialValue: null,
                          title: '选择签收方式',
                          titleStyle: TextStyle(fontSize: 20, color: Colors.blue),
                          selectedColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          additionalActions: [
                            // Divider(),
                            // ListTile(
                            //   title: Text('取消', style: TextStyle(color: Colors.grey)),
                            //   onTap: () => Navigator.pop(context),
                            // ),
                          ],
                        );
                        if (result != null) {
                          print('选择的签收方式: ${result['value']}');
                          return result['value'];
                        }
                        return null;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择签收方式';
                        }
                        return null;
                      },
                    ),
                    // 签收方式
                    SizedBox(height: 20),

                    // 图片上传区域
                    SizedBox(height: 8),
                    // 图片上传
                    MultiImagePicker(
                      maxCount: 3,
                      onImageUploaded: (imagePaths) {
                        _receiptImageUrls = imagePaths;
                      },
                    ),
                    SizedBox(height: 20),

                    // 客户签字板
                    SignaturePreview(
                      onSignatureChanged: (url) async {
                        print("客户签字: $url");
                        setState(() {
                          _signatureImageUrl = url;
                          _statusMessage = url == null
                              ? '签名已清除，请重新签名'
                              : '签名已完成';
                        });
                      },
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // 底部固定提交按钮
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submit,
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