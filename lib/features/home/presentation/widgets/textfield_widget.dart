import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Loyiha bo'ylab ishlatiladigan universal TextField widget
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final String? prefix;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.prefix,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 15, color: AppColors.darkGrey),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          color: AppColors.darkGrey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.purple, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
    );
  }
}