import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';

class ContactWidget extends StatelessWidget {
  final String svg;
  final String text;
  final String contact;
  const ContactWidget({super.key, required this.svg, required this.text, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164.w,
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: BoxBorder.all(color: Color(0xffD7DADC)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 10,left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(svg),
            SizedBox(height: 6.h,),
            Text(text, style: TextStyle(color: AppColors.grey, fontSize: 16, fontWeight: FontWeight.w400),),
            SizedBox(height: 6.h,),
            Text(contact, style: TextStyle(color: AppColors.darkGrey, fontSize: 14, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }
}
