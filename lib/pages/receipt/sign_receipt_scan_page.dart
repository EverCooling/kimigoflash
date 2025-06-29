import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kimiflash/pages/receipt/sign_receipt_scan_controller.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/pages/widgets/multi_album_picker_field.dart';
import 'package:kimiflash/pages/widgets/signature_preview.dart';
import 'package:riverpod/src/framework.dart';
import '../../http/api/auth_api.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_method_bottom_sheet.dart';
import '../widgets/signature_pad.dart';
import '../widgets/signature_preview.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String _kyInStorageNumber = '';
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

  Future<void> _submit() async {
    print('提交按钮点击'); // 调试输出

    final form = _formKey.currentState;
    if (form?.saveAndValidate() ?? false) {
      try {
        // 获取表单值
        final Map<String, dynamic> formData = form!.value;
        final String trackingNumber = formData['trackingNumber'] ?? '';
        final String signMethod = formData['signMethod'] ?? '';

        HUD.show(context);
        // 调用API提交数据
        final response = await _authApi.DeliveryManAddOrderDelivery({
          'kyInStorageNumber': trackingNumber,
          'signForType': signMethod,
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
    } else {
      print('表单验证失败');
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
                      hintText: '请输入运单号',
                      prefixIcon: Icons.vertical_distribute,
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
                    ),
                    SizedBox(height: 20),

                    CustomDropdownField(
                      name: 'signMethod',
                      labelText: '请选择异常原因',
                      items: controller.methods,
                      initialValue: null,
                      onTap: (context) async {
                        final result = await SignMethodBottomSheet.show(
                          context,
                          methods: controller.methods,
                          initialValue: null,
                          title: '选择派件方式',
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
                        if (result != null) {
                          print('报巴巴啦 ====== ');

                          print(result['value']);
                          return result['value'];
                        }
                        return null;
                      },
                    ),
                    // 签收方式
                    SizedBox(height: 20),

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

                    // 客户签字板
                    SignaturePreview(
                      onSignatureChanged: (url) async {
                        print("客户签字");
                        setState(() {
                          _signatureImageUrl = url;
                          _signatureImageUrl = url == null
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
              onPressed: () {
                print('提交按钮点击'); // 调试输出
                _submit();

              },
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
