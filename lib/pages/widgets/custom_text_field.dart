import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextField extends StatelessWidget {
  final String name;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool isLoading;
  final VoidCallback? onSuffixPressed;
  final ValueChanged<String?>? onSubmitted;  // 修改类型
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final IconData? suffixIcon;// 可选 controller
  final FormFieldValidator<String>? validator; // 添加 validator 支持

  const CustomTextField({
    Key? key,
    required this.name,
    required this.labelText,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isLoading = false,
    this.onSuffixPressed,
    this.onSubmitted,
    this.initialValue,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      controller: controller, // ✅ 使用传入的 controller
      name: name,
      validator: validator,
      enabled: enabled,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.red)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixPressed)
            : null,
        // suffixIcon: isLoading
        //     ? SizedBox(
        //   width: 20,
        //   height: 20,
        //   child: CircularProgressIndicator(strokeWidth: 2),
        // )
        //     : IconButton(
        //   icon: Icon(Icons.barcode_reader),
        //   onPressed: onSuffixPressed,
        // ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
