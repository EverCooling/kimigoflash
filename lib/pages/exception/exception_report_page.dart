import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/widgets/limit_description_box.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/pages/widgets/custom_dropdown_field.dart';
import 'package:kimiflash/pages/widgets/multi_image_picker.dart';
import 'package:kimiflash/pages/widgets/sign_method_bottom_sheet.dart';
import 'package:kimiflash/pages/exception/exception_report_controller.dart';
import '../widgets/custom_text_field.dart';

class ExceptionReportPage extends StatefulWidget {
  const ExceptionReportPage({super.key});

  @override
  State<ExceptionReportPage> createState() => _ExceptionReportPageState();
}

class _ExceptionReportPageState extends State<ExceptionReportPage> {
  final controller = Get.put(ExceptionReportController());
  List<String>? _receiptImageUrls;
  final AuthApi _authApi = AuthApi();
  String? deliveryFailType = '请选择异常原因'; // 默认值设置为提示文字
  Map<String, dynamic>? deliveryItem;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    deliveryItem = Get.arguments as Map<String, dynamic>?;

    // 检查deliveryItem是否有值并填充单号
    if (deliveryItem != null && deliveryItem!.containsKey('kyInStorageNumber')) {
      final orderNumber = deliveryItem!['kyInStorageNumber'].toString();

      // 使用WidgetsBinding确保在Widget渲染完成后再设置值
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 直接通过表单设置值
        _formKey.currentState?.fields['kyInStorageNumber']?.didChange(orderNumber);
      });
    }
  }

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

  // 验证订单号
  _verifyOrder(String orderNumber) async {
    // 表单验证
    if (orderNumber.isEmpty) {
      return false;
    }

    HUD.show(context);
    try {
      final response = await _authApi.checkOrderAbnormalRegister({
        "kyInStorageNumber": orderNumber
      });
      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
      } else {
        // 清除输入框
        // _formKey.currentState?.fields['kyInStorageNumber']?.didChange('');
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      HUD.hide();
    }
  }

  // 异常登记请求接口
  Future<void> _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Get.snackbar('错误', '请检查表单输入');
      return;
    }

    final formData = _formKey.currentState!.value;
    print("表单数据: $formData");

    if (_receiptImageUrls == null || _receiptImageUrls!.isEmpty) {
      Get.snackbar('错误', '请至少上传一张凭证图片');
      return;
    }

    HUD.show(context);
    try {
      final response = await _authApi.AddDeliveryManAbnormalRegister({
        "kyInStorageNumber": formData['kyInStorageNumber'] ?? '',
        "deliveryFailType": _getDeliveryFailType(formData['deliveryFailType']),
        "failTitle": formData['failTitle'] ?? '默认异常标题',
        "deliveryFailUrl": _receiptImageUrls?.join(',') ?? '',
        "customerCode": "10010"
      });

      if (response.code == 200) {
        Get.snackbar('成功', '异常登记提交成功');
        Get.back(result: true); // 只在成功时返回
      } else {
        // 清除单号
        _formKey.currentState?.fields['kyInStorageNumber']?.didChange('');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                name: 'kyInStorageNumber',
                enabled: true,
                labelText: '扫描单号',
                hintText: '请输入运单号',
                prefixIcon: Icons.vertical_distribute,
                suffixIcon: Icons.barcode_reader,
                onTapOutside: (event) async {
                  // 失去焦点
                  FocusScope.of(context).unfocus();
                  final formState = _formKey.currentState;
                  if (formState != null) {
                    // 获取当前输入的订单号
                    final currentValue = formState.fields['kyInStorageNumber']?.value as String?;
                    if (currentValue != null && currentValue.isNotEmpty) {
                      // 调用校验接口
                      await _verifyOrder(currentValue);
                    } else {
                      // 订单号为空时的处理
                      Get.snackbar('提示', '请先输入或扫描订单号');
                    }
                  }
                },
                onSuffixPressed: () async {
                  FocusScope.of(context).unfocus();

                  final barcodeResult = await Get.toNamed('/scanner');
                  if (barcodeResult != null) {
                    _formKey.currentState?.fields['kyInStorageNumber']?.didChange(barcodeResult);
                    await _verifyOrder(barcodeResult);
                  }
                },
                onSubmitted: (value) async {
                  FocusScope.of(context).unfocus();
                  if (value != null && value.isNotEmpty) {
                    await _verifyOrder(value);
                  }
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
              // 异常原因选择
              FormBuilderField(
                name: 'deliveryFailType',
                initialValue: '请选择异常原因', // 设置表单初始值
                validator: (value) {
                  if (value == null || value.toString() == '请选择异常原因') {
                    return '请选择异常原因';
                  }
                  return null;
                },
                builder: (field) {
                  return CustomDropdownField(
                    name: 'deliveryFailType',
                    labelText: '请选择异常原因',
                    items: ['请选择异常原因'] + controller.reasons, // 选项列表添加默认提示
                    initialValue: field.value.toString(),
                    onTap: (context) async {
                      // 过滤掉默认提示项再显示选项
                      final filteredReasons = controller.reasons.where((reason) => reason != '请选择异常原因').toList();
                      final result = await SignMethodBottomSheet.show(
                        context,
                        methods: filteredReasons,
                        initialValue: field.value.toString() == '请选择异常原因' ? null : field.value.toString(),
                        title: '选择异常原因',
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
                      return field.value.toString();
                    },
                    validator: (value) {
                      return value == null || value == '请选择异常原因' ? '请选择异常原因' : null;
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // 调用封装的异常描述组件
              LimitedTextFormField(
                name: 'failTitle', // 字段名必须唯一且正确
                labelText: '异常描述',
                hintText: '请输入详细异常情况（最多200字）',
                maxLength: 200,
                // 可自定义验证器（可选）
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入异常描述'; // 自定义提示
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // 图片上传
              MultiImagePicker(
                orderNumber: _formKey.currentState?.fields['kyInStorageNumber']?.value as String?,
                maxCount: 3,
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