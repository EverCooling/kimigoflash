// exception_report_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exception_report_controller.dart';

class ExceptionReportPage extends StatelessWidget {
  late final ExceptionReportController controller;

  ExceptionReportPage({Key? key}) : super(key: key) {
    controller = Get.put(ExceptionReportController());
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
            // 单号输入
            TextFormField(
              controller: TextEditingController(text: controller.trackingNumber.value)
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.trackingNumber.value.length)),
              onChanged: (value) => controller.trackingNumber(value),
              decoration: InputDecoration(labelText: '单号', hintText: '请输入运单号'),
            ),

            SizedBox(height: 20),

            // 异常原因 下拉选择
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedReason.value.isEmpty
                  ? null
                  : controller.selectedReason.value,
              hint: Text('请选择异常原因'),
              items: controller.reasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) => controller.selectedReason(value ?? ''),
              decoration: InputDecoration(labelText: '异常原因'),
            )),

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
            Text('包裹/现场图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                // TODO: 调用图片选择器或相机
                controller.selectedImage("图片已上传");
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(controller.selectedImage.value.isNotEmpty
                        ? controller.selectedImage.value
                        : '点击上传图片')),
                    Icon(Icons.upload_outlined),
                  ],
                ),
              ),
            ),

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
    );
  }
}
