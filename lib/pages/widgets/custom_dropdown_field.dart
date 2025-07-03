// lib/widgets/custom_dropdown_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomDropdownField extends StatelessWidget {
  final String name;
  final String labelText;
  final List<String> items;
  final Future<String?> Function(BuildContext) onTap;
  final String? initialValue;
  final ValueChanged<int>? onIndexChanged;

  const CustomDropdownField({
    Key? key,
    required this.name,
    required this.labelText,
    required this.items,
    required this.onTap,
    this.initialValue,
    this.onIndexChanged,
    required String? Function(dynamic value) validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
      name: name,
      initialValue: initialValue,
      builder: (FormFieldState<dynamic> field) {
        return InkWell(
          onTap: () async {
            final selected = await onTap(context);
            if (selected != null) {
              final int index = items.indexOf(selected);
              field.didChange(selected);
              if (onIndexChanged != null && index != -1) {
                onIndexChanged!(index);
              }
            }
          },
          child: InputDecorator(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  field.value?.toString() ?? '请选择',
                  style: TextStyle(fontSize: 16),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
