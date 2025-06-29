import 'package:flutter/material.dart';

// lib/widgets/sign_method_bottom_sheet.dart
import 'package:flutter/material.dart';

class SignMethodBottomSheet {
  static Future<Map<String, dynamic>?> show(
      BuildContext context, {
        required List<String> methods,
        String? initialValue,
        String? title = '选择签收方式', // 允许自定义标题
        TextStyle? titleStyle, // 标题样式
        EdgeInsetsGeometry? padding, // 内边距
        Color? selectedColor = Colors.red, // 选中颜色
        ShapeBorder? shape, // 底部弹窗形状
        List<Widget>? additionalActions, // 底部附加操作
      }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: padding ?? EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: titleStyle ?? TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
              ],
              ...methods.asMap().entries.map((entry) => ListTile(
                title: Text(entry.value),
                trailing: initialValue == entry.value
                    ? Icon(Icons.check, color: selectedColor)
                    : null,
                onTap: () => Navigator.pop(context, {
                  'value': entry.value,
                  'index': entry.key,
                }),
              )),
              if (additionalActions != null) ...[
                SizedBox(height: 8),
                ...additionalActions,
              ],
            ],
          ),
        );
      },
    );
  }
}