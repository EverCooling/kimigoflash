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

  const CustomTextField({
    Key? key,
    required this.name,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.isLoading = false,
    this.onSuffixPressed,
    this.onSubmitted,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
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
        suffixIcon: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(
          icon: Icon(Icons.barcode_reader),
          onPressed: onSuffixPressed,
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
