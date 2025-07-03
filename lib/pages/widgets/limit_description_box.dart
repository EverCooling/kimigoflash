import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ExceptionDescriptionField extends StatelessWidget {
  final String name;
  final int maxLength;
  final String? initialValue;
  final FormFieldValidator<String>? validator;

  const ExceptionDescriptionField({
    Key? key,
    required this.name,
    this.maxLength = 200,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: name,
          decoration: InputDecoration(
            labelText: '异常描述',
            hintText: '请输入详细异常情况（最多$maxLength字）',
            // 红色边框设置
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (value) {
            // 可选：添加字数变化回调
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入异常描述';
            }
            if (value.length > maxLength) {
              return '不能超过$maxLength字';
            }
            return validator?.call(value);
          },
          initialValue: initialValue,
        ),
        // 字数提示
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildCharacterCountIndicator(name, context),
        ),
      ],
    );
  }

  // 构建字数提示组件
  Widget _buildCharacterCountIndicator(String fieldName, BuildContext context) {
    return StreamBuilder<String>(
      stream: FormBuilder.of(context)?.fields[fieldName]?.value,
      builder: (context, snapshot) {
        final value = snapshot.data ?? '';
        final length = value.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$length/$maxLength',
              style: TextStyle(
                color: length > maxLength ? Colors.red : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}