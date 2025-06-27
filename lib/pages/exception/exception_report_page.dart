// exception_report_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../http/api/auth_api.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multi_album_picker_field.dart';
import '../widgets/sign_method_bottom_sheet.dart';
import 'exception_report_controller.dart';

class ExceptionReportPage extends StatefulWidget{
  final Map<String, dynamic> deliveryItem;

  const ExceptionReportPage({super.key, required this.deliveryItem});

  @override
  State<ExceptionReportPage> createState() => _ExceptionReportPageState();

}

class _ExceptionReportPageState extends State<ExceptionReportPage> {
  final controller = Get.put(ExceptionReportController());
  bool _isLoading = false;

  final AuthApi _authApi = AuthApi();

  Future<void> _verifyOrder(String orderNumber) async {
    final isValid = RegExp(r'^(GR|UKG).+').hasMatch(orderNumber);
    if (!isValid) {
      Get.snackbar('错误', '单号有误，请重新操作');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authApi.DeliverManScanOutWarehouse({
        'kyInStorageNumber': orderNumber,
        'customerCode': '10010',
        "lang":"zh"
      });
      setState(() {
        _isLoading = false;
      });

      if (response.code == 200) {
        Get.snackbar('成功', '单号验证成功');
      } else {
        Get.snackbar('失败', response.msg ?? '验证失败');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: CircularProgressIndicator(),
        child: Scaffold(
          appBar: AppBar(title: Text('异常登记')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomTextField(
                  name: 'trackingNumber',
                  labelText: '扫描单号',
                  hintText: '请输入运单号',
                  prefixIcon: Icons.vertical_distribute,
                  suffixIcon: Icons.barcode_reader,
                  onSuffixPressed: () async {
                    final barcodeResult = await Get.toNamed('/scanner');
                    if (barcodeResult != null) {
                      // await _verifyOrder(barcodeResult);
                    }
                  },
                  onSubmitted: (value) async {
                    // if (value != null) await _verifyOrder(value);
                  },
                ),
                // // 单号输入
                // TextFormField(
                //   controller: TextEditingController(text: controller.trackingNumber.value)
                //     ..selection = TextSelection.fromPosition(
                //         TextPosition(offset: controller.trackingNumber.value.length)),
                //   onChanged: (value) => controller.trackingNumber(value),
                //   decoration: InputDecoration(labelText: '单号', hintText: '请输入运单号'),
                // ),

                SizedBox(height: 20),

                // // 异常原因 下拉选择
                // Obx(() => DropdownButtonFormField<String>(
                //   value: controller.selectedReason.value.isEmpty
                //       ? null
                //       : controller.selectedReason.value,
                //   hint: Text('请选择异常原因'),
                //   items: controller.reasons.map((reason) {
                //     return DropdownMenuItem<String>(
                //       value: reason,
                //       child: Text(reason),
                //     );
                //   }).toList(),
                //   onChanged: (value) => controller.selectedReason(value ?? ''),
                //   decoration: InputDecoration(labelText: '异常原因'),
                // )),
                // 签收方式
                CustomDropdownField(
                  name: 'signMethod',
                  labelText: '请选择异常原因',
                  items: controller.reasons,
                  initialValue: null,
                  onTap: (context) async {
                    return await
                    // 高级使用方式（自定义样式）
                    SignMethodBottomSheet.show(
                      context,
                      methods: controller.reasons,
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
                  },
                ),
                SizedBox(height: 20),

                // 异常描述 输入框
                TextFormField(
                  controller: TextEditingController(text: controller.description.value)
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.description.value.length)),
                  onChanged: (value) => controller.description(value),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '异常描述',
                    hintText: '请输入详细异常情况',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),


                // 图片上传区域
                // Text('包裹/现场图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // SizedBox(height: 8),
                // InkWell(
                //   onTap: () {
                //     // TODO: 调用图片选择器或相机
                //     controller.selectedImage("图片已上传");
                //   },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.grey),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Obx(() => Text(controller.selectedImage.value.isNotEmpty
                //             ? controller.selectedImage.value
                //             : '点击上传图片')),
                //         Icon(Icons.upload_outlined),
                //       ],
                //     ),
                //   ),
                // ),
                // 图片上传区域
                // 在页面中使用 MultiAlbumPickerField
                MultiAlbumPickerField(
                  label: '包裹/现场图片',
                  maxSelection: 5,
                  onImageUploaded: (imagePaths) {
                    // 处理上传后的图片路径列表
                    print('上传成功：$imagePaths');
                  },
                ),
                SizedBox(height: 20),

                SizedBox(height: 32),

                // 提交按钮
                ElevatedButton(
                  onPressed: controller.submit,
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  child: Text('提交'),
                ),
              ],
            ),
          ),
        )
    );
  }
}
