import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteProfileDialog extends StatelessWidget {
  const DeleteProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mahsulotni o‘chirish",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE86F6F),
              ),
            ),
            SizedBox(height: 10.h),

            Text(
              "Haqiqatan ham bu mahsulotni butunlay o‘chirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo‘lmaydi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFE86F6F),
              ),
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: const Color(0xFFFFB3B3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Bekor qilish",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFE86F6F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE86F6F), Color(0xFFCF4F4F)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Ha, o'chirish",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
