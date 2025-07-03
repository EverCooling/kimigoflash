// exception_report_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/pages/widgets/custom_dropdown_field.dart';
import 'package:kimiflash/pages/widgets/multi_image_picker.dart';
import 'package:kimiflash/pages/widgets/sign_method_bottom_sheet.dart';
import 'package:kimiflash/pages/exception/exception_report_controller.dart';

import '../widgets/custom_text_field.dart';

class ExceptionReportPage extends StatefulWidget{
  final Map<String, dynamic> deliveryItem;

  const ExceptionReportPage({super.key, required this.deliveryItem});

  @override
  State<ExceptionReportPage> createState() => _ExceptionReportPageState();

}

class _ExceptionReportPageState extends State<ExceptionReportPage> {
  final controller = Get.put(ExceptionReportController());
  List<String>? _receiptImageUrls;
  final AuthApi _authApi = AuthApi();
  String? orderNumber;
  String? deliveryFailType;
  String? failTitle;

  final _formKey = GlobalKey<FormBuilderState>();

  int _getDeliveryFailType(String deliveryFailType) {
    switch (deliveryFailType) {
      case '电话无人接听':
        return 1;
      case '收件人不在家':
        return 2;
      case '地址错误':
        return 3;
      default:
        return 0;
    }
  }

  bool _validateForm() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      Get.snackbar('错误', '请检查表单输入');
      return false;
    }

    formState.save();

    if (deliveryFailType == null) {
      Get.snackbar('错误', '请选择异常原因');
      return false;
    }

    return true;
  }

  //异常登记请求接口
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('错误', '请检查表单输入');
      return;
    }

    final formData = _formKey.currentState!.value;

    HUD.show(context);
    try {
      final response = await _authApi.AddDeliveryManAbnormalRegister( {
        "kyInStorageNumber": formData['trackingNumber'] ?? '',
        "deliveryFailType": _getDeliveryFailType(formData['deliveryFailType']),
        "failTitle": formData['failTitle'] ?? '默认异常标题',
        "deliveryFailUrl": _receiptImageUrls?.join(',') ?? '',
        "customerCode": "10010"
      });

      if (response.code == 200) {
        Get.snackbar('成功', '异常登记提交成功');
        Navigator.pop(context);
      } else {
        Get.snackbar('失败', response.msg ?? '未知错误');
      }

    } catch (e) {
      print(e);
      Get.snackbar('网络错误', e.toString());
    } finally {
      HUD.hide();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('异常登记')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    _formKey.currentState?.fields['kyInStorageNumber']?.didChange(barcodeResult);
                  }
                },
                onSubmitted: (value) async {

                },
              ),
              SizedBox(height: 20),
              // 异常原因选择
              FormBuilderField(
                name: 'deliveryFailType',
                validator: (value) {
                  if (value == null || value.toString().isEmpty) {
                    return '请选择异常原因';
                  }
                  return null;
                },
                initialValue: deliveryFailType,
                builder: (field) {
                  return CustomDropdownField(
                    name: 'signMethod',
                    labelText: '请选择异常原因',
                    items: controller.reasons,
                    initialValue: field.value,
                    onTap: (context) async {
                      final result = await SignMethodBottomSheet.show(
                        context,
                        methods: controller.reasons,
                        initialValue: field.value,
                        title: '选择派件方式',
                        titleStyle: TextStyle(fontSize: 20, color: Colors.blue),
                        selectedColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          deliveryFailType = result['value'];
                          field.didChange(result['value']);
                        });
                        return result['value'];
                      }
                      return field.value;
                    }, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请选择签收方式';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // 异常描述输入框
              FormBuilderTextField(
                name: 'failTitle',
                decoration: InputDecoration(
                  labelText: '异常描述',
                  hintText: '请输入详细异常情况',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.toString().isEmpty) {
                    return '请输入异常描述';
                  }
                  return null;
                },
                onSaved: (value) => failTitle = value,
                initialValue: failTitle,
              ),

              SizedBox(height: 20),

              // 图片上传
              MultiImagePicker(
                maxCount: 6,
                onImageUploaded: (imagePaths) {
                  _receiptImageUrls = imagePaths;
                },
              ),

              SizedBox(height: 32),

              // 提交按钮
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
