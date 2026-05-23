import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String hint;
  final void Function(T?) onChanged;

  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: AppTextStyles.body(context),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.toString()));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
