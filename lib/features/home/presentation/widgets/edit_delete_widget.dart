import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:market_store/features/home/presentation/pages/product_edit_page.dart';
import '../../../../core/constants/app_colors.dart';
import 'delete_widget.dart';

class EditDeleteWidget extends StatelessWidget {
  const EditDeleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => ProductEditPage(),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                IconlyLight.edit_square,
                size: 18,
                color: AppColors.purple,
              ),
            ),
          ),

          const SizedBox(width: 4),

          InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => DeleteProfileDialog(
                  title: 'Mahsulotni o‘chirish',
                  description:
                      'Haqiqatan ham bu mahsulotni butunlay o‘chirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo‘lmaydi.',
                  gestureDetectorNo: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: Color(0xffECE5E5FF)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Bekor qilish",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFC23AF5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  gestureDetectorYes: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC86EF9), Color(0xFF8B7CF6)],
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
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(IconlyLight.delete, size: 18, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
