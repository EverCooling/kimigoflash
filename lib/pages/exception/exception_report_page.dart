// exception_report_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../http/api/auth_api.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multi_album_picker_field.dart';
import '../widgets/multi_image_picker.dart';
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
  List<String>? _receiptImageUrls;
  final AuthApi _authApi = AuthApi();
  String? orderNumber;
  String? failTitle;

  //异常登记请求接口
  Future<void> _submit() async {

    HUD.show(context);
    try {
      final response = await _authApi.AddDeliveryManAbnormalRegister( {
        "kyInStorageNumber": orderNumber,
        "deliveryFailType": 0,
        "failTitle": "string",
        "deliveryFailUrl": "string",
        "customerCode": "10010"
      });

    } catch (e) {
      print(e);
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
                if(barcodeResult != null){
                  orderNumber = barcodeResult;
                }
              },
              onSubmitted: (value) async {

              },
            ),


            SizedBox(height: 20),

            // 签收方式
            CustomDropdownField(
              name: 'signMethod',
              labelText: '请选择异常原因',
              items: controller.reasons,
              initialValue: null,
              onTap: (context) async {
                final result = await SignMethodBottomSheet.show(
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
                if (result != null) {
                  return result['value'];
                }
                return null;
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

            MultiImagePicker(
              maxCount: 6,
              onImageUploaded: (imagePaths) {
                _receiptImageUrls = imagePaths;
                print('选中的图片: ${imagePaths}');
              },
            ),

            SizedBox(height: 32),

            // 提交按钮
            ElevatedButton(
              onPressed: ()=> {

              },
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
