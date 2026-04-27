import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_store/features/home/presentation/pages/product_detail_page.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_delete_widget.dart';

class ProductCardWidget extends StatelessWidget {
  final String title;
  final String oldPrice;
  final String newPrice;
  final String status;
  final VoidCallback onAdd;

  const ProductCardWidget({
    super.key,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    required this.status,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>  ProductDetailPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 4, right: 4, top: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 130.h,
                    width: double.infinity,
                    color: const Color(0xffEEEEEE),
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(top: 4, right: 4, child: EditDeleteWidget()),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                status,
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        oldPrice,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "$newPrice / metr",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xff2F3542),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
