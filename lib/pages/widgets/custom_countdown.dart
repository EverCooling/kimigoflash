import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomFormDropdown extends StatelessWidget {
  final String name;
  final String labelText;
  final List<String> items;
  final Function(String?)? onChanged; // ✅ 新增：用于接收 onChange 事件的回调

  const CustomFormDropdown({
    Key? key,
    required this.name,
    required this.labelText,
    required this.items,
    this.onChanged, // ✅ 初始化新增参数
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<String>(
      name: name,
      items: items.map((method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(method),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
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
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      onChanged: onChanged, // ✅ 使用传入的 onChanged 回调
    );
  }
}
