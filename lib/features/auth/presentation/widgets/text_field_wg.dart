import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldWidgetBoard extends StatefulWidget {
  final TextEditingController? controller;
  final String text;
  final String? errorText;
  final TextCapitalization? textCapitalization;
  final bool readOnly;
  final bool obscureText;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final double? height;

  const TextFieldWidgetBoard({
    super.key,
    this.controller,
    required this.text,
    required this.obscureText,
    this.suffixIcon,
    this.keyboardType, this.errorText, this.onChanged, required this.readOnly, this.textCapitalization, this.prefixIcon, this.height,
  });

  @override
  State<TextFieldWidgetBoard> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidgetBoard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: TextField(
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          errorText: widget.errorText,
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon,
          hintText: widget.text,
          hintStyle: GoogleFonts.poppins(color: Color(0xffA4B0BE)),
          filled: true,
          fillColor:  Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              width: 1.5,
              color: Color(0xFFE5E7EB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xff6A85F1),
              width: 1.w,
            ),
          ),
        ),
      ),
    );
  }
}
