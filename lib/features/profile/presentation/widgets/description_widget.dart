import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DescriptionWidget extends StatelessWidget {
  final String? hintText;
  final int? maxLine;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;

  const DescriptionWidget({
    super.key,
    this.hintText,
    this.maxLine,
    required this.controller,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLine,
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.darkGrey),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0D5FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC23AF5), width: 1.5),
        ),
      ),
    );
  }
}
