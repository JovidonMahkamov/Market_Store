import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class EditTextFieldWidget extends StatelessWidget {
  final String? hintText;
  final int? maxLine;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;

  const EditTextFieldWidget({
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
      style: TextStyle(fontSize: 14.sp, color: AppColors.darkGrey),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.grey),

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.purple, size: 20.sp)
            : null,

        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE0D5FF), width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFC23AF5), width: 1.5),
        ),
      ),
    );
  }
}
