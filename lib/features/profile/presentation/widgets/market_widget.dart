import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class MarketWidget extends StatefulWidget {
  const MarketWidget({super.key});

  @override
  State<MarketWidget> createState() => _MarketWidgetState();
}

class _MarketWidgetState extends State<MarketWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: BoxBorder.all(color: AppColors.purple)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Royal Curtains",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Premium parda do’koni",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    SvgPicture.asset("assets/home/Heart.svg"),
                    SizedBox(width: 6.w),
                    Text(
                      "Rulon pardalar",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    SvgPicture.asset("assets/home/Location.svg"),
                    SizedBox(width: 6.w),
                    Text(
                      "Toshkent, Abu Saxiy",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );

  }
}
