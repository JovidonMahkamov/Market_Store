import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';

class NotificationWg extends StatelessWidget {
  final String title;
  final String category;

  const NotificationWg({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 6.h,),
                  Row(
                    children: [
                      SvgPicture.asset("assets/home/Calendar.svg"),
                      SizedBox(width: 12.w,),
                      Text("12-iyun 2026 soat 12:22",style: TextStyle(
                        color: Color(0xff898794)
                      ),)
                    ],
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}