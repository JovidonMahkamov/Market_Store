import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageCardWidget extends StatelessWidget {
  final File imageFile;
  final int index;
  final int total;
  final VoidCallback onDelete;
  final Widget deleteButton;

  const ImageCardWidget({
    super.key,
    required this.imageFile,
    required this.index,
    required this.total,
    required this.onDelete,
    required this.deleteButton,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 160.w,
          height: 160.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${index + 1}/$total',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(onTap: onDelete, child: deleteButton),
        ),
      ],
    );
  }
}
