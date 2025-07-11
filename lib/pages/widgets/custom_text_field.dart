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
    this.autofocus = false,
    this.onChanged,
    this.onTapOutside,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: FormBuilderTextField(
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
          errorStyle: const TextStyle(color: Colors.red),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
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
          FocusScope.of(context).unfocus();
          onSubmitted?.call(value);
        },
      ),
    );
  }
}