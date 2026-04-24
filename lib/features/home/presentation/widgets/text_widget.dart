import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;


  const TextWidget({super.key, required this.text, this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.darkGrey,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
