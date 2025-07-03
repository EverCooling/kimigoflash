import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LimitedTextFormField extends StatefulWidget {
  final String name;
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
  late StreamSubscription<FormBuilderFieldState?>? _subscription;
  FormBuilderState? _formState;

  @override
  void initState() {
    super.initState();
    // 使用WidgetsBinding确保在组件完全初始化后再进行订阅
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formState = FormBuilder.of(context);
      _initSubscription();
    });
  }

  void _initSubscription() {
    if (_formState == null) return;
    _subscription = _formState!.fieldValueStream(widget.name).listen((_) {
      // 空监听，仅保持订阅以触发重建
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依赖变化时更新FormBuilderState引用
    _formState = FormBuilder.of(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_formState == null) {
      // 表单状态未初始化时显示加载状态或空组件
      return const SizedBox();
    }

    final fieldState = _formState!.fields[widget.name];
    final value = fieldState?.value?.toString() ?? '';
    final length = value.length;
    final isMaxLengthReached = length >= widget.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: widget.name,
          initialValue: widget.initialValue,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
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
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入$widget.labelText';
            }
            if (value.length > widget.maxLength) {
              return '不能超过${widget.maxLength}字';
            }
            return widget.validator?.call(value);
          },
        ),
        // 字数提示
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$length/${widget.maxLength}',
                style: TextStyle(
                  color: isMaxLengthReached ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 扩展方法实现
extension FormBuilderStateExtension on FormBuilderState {
  Stream<FormBuilderFieldState?> fieldValueStream(String name) {
    return fields[name]?.value ?? '';
  }
}
