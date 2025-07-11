import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class LimitedTextFormField extends StatefulWidget {
  final String name; // 表单字段名（必须与FormBuilder绑定）
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final String labelText;
  final String hintText;

  const LimitedTextFormField({
    Key? key,
    required this.name,
    this.initialValue,
    this.validator,
    this.maxLength = 200,
    this.labelText = '输入内容',
    this.hintText = '请输入内容',
  }) : super(key: key);

  @override
  _LimitedTextFormFieldState createState() => _LimitedTextFormFieldState();
}

class _LimitedTextFormFieldState extends State<LimitedTextFormField> {

  @override
  Widget build(BuildContext context) {
    // 实时获取最新的表单状态（关键修复）
    final formState = FormBuilder.of(context);
    if (formState == null) {
      return const SizedBox(); // 确保父级有FormBuilder
    }

    // 实时获取当前字段的值（从最新的formState中获取）
    final fieldValue = formState.fields[widget.name]?.value?.toString() ?? '';
    final length = fieldValue.length;
    final isMaxLengthReached = length >= widget.maxLength;

    return Card(
      color: Colors.white,
      elevation:4,
      child: FormBuilderTextField(
          name: widget.name, // 字段名必须与父级FormBuilder中的定义一致
          initialValue: widget.initialValue,
          enabled: true,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: Colors.black),
            hintText: widget.hintText,
            errorStyle: const TextStyle(color: Colors.red),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          // 验证逻辑：优先使用外部传入的validator，否则使用默认
          validator: widget.validator ?? (value) {
            if (value == null || value.isEmpty) {
              return '请输入${widget.labelText}';
            }
            if (value.length > widget.maxLength) {
              return '不能超过${widget.maxLength}字';
            }
            return null;
          },
          onChanged: (value) {
            Future.delayed(Duration.zero, () {
              if (mounted) {
                formState.validate(); // 验证全表单（包含当前字段）
              }
            });
          },
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
        ),

        // 字数提示（基于实时值）
        // Padding(
        //   padding: const EdgeInsets.only(top: 4),
        //   child: Align(
        //     alignment: Alignment.centerRight,
        //     child: Text(
        //       '$length/${widget.maxLength}',
        //       style: TextStyle(
        //         color: isMaxLengthReached ? Colors.red : Colors.grey,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
        // ),

    );
  }
}