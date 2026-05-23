import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;

  const AppText(this.text, {super.key, this.style, this.align, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align ?? TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style ?? AppTextStyles.body(context),
    );
  }
}
