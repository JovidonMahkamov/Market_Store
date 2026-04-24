import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
class ElevatedButtonWg extends StatelessWidget {
  final double? width;
  final double? height;
  final void Function()? onPressed;
  final String text;
  final Color textColor;
  const ElevatedButtonWg({super.key, required this.onPressed,required this.text, this.width,this.height, required this.textColor,});
  @override
  Widget build (BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: AppColors.buttonGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B52D8)
                .withOpacity(0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withOpacity(0.15),
          onTap: onPressed,
          child:  Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

}

