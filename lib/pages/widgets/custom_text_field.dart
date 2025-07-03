

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextField extends StatelessWidget {
  final String name;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final VoidCallback? onSuffixPressed;
  final ValueChanged<String?>? onSubmitted;
  final TextEditingController? controller;
  final IconData? suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.name,
    required this.labelText,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.onSuffixPressed,
    this.onSubmitted,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      validator: validator,
      controller: controller,
      enabled: enabled,
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
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.red) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixPressed)
            : null,
      ),
      onSubmitted: onSubmitted,
    );
  }
}