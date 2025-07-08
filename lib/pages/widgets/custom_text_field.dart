import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextField extends StatelessWidget {
  final String name;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final VoidCallback? onSuffixPressed;
  final GestureTapCallback? onTap;
  final ValueChanged<String?>? onSubmitted;
  final TextEditingController? controller;
  final IconData? suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool autofocus;
  final TapRegionCallback? onTapOutside;
  final ValueChanged? onChanged;

  CustomTextField({
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
    this.autofocus = false,
    this.onChanged,
    this.onTapOutside,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      validator: validator,
      controller: controller,
      enabled: enabled,
      autofocus: false,
      textInputAction: TextInputAction.done,
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
            ? IconButton(icon: Icon(suffixIcon), onPressed: (){
          FocusScope.of(context).unfocus();
          onSuffixPressed?.call();
        })
            : null,
      ),
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
      },
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        onTapOutside?.call(event);
      },
      onTap: (){
        onTap?.call();
      },
      onChanged: onChanged,
      onSubmitted: (value) {
        onSubmitted?.call(value);
        FocusScope.of(context).unfocus();
      },
    );
  }
}