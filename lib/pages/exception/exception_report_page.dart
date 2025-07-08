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
  Map<String,dynamic>? deliveryItem;

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
        // 设置控制器的值
        controller.scanController.text = orderNumber;

        // 更新表单字段的值
        if (_formKey.currentState != null) {
          _formKey.currentState?.fields['kyInStorageNumber']?.didChange(orderNumber);
        }
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

  // 异常登记请求接口
  Future<void> _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Get.snackbar('错误', '请检查表单输入');
      return;
    }

    final formData = _formKey.currentState!.value;
    print("表单数据: $formData");

    if (deliveryFailType == '请选择异常原因') {
      // 如果仍为默认值，从表单获取实际选择的值
      deliveryFailType = formData['deliveryFailType'];
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
                controller: controller.scanController,
                prefixIcon: Icons.vertical_distribute,
                suffixIcon: Icons.barcode_reader,
                onSuffixPressed: () async {
                  FocusScope.of(context).unfocus();

                  final barcodeResult = await Get.toNamed('/scanner');
                  if (barcodeResult != null) {
                    _formKey.currentState?.fields['kyInStorageNumber']?.didChange(barcodeResult);
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
                name: 'description',
                labelText: '异常描述',
                hintText: '请输入详细异常情况（最多200字）',
                maxLength: 200,
              ),

              SizedBox(height: 20),

              // 图片上传
              MultiImagePicker(
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