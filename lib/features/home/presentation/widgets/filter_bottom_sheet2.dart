import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterBottomSheet2 extends StatefulWidget {
  final Function(String) onSelected;

  const FilterBottomSheet2({super.key, required this.onSelected});

  @override
  State<FilterBottomSheet2> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet2> {

  int selectedIndex = -1;

  final List<String> filters = [
    "Kolso",
    "Bunon",
    "Elit Parda",
    "Izabella Parda",
    "Karnez",
  ];

  final gradient = const LinearGradient(
    colors: [
      Color(0xFF6A85F1),
      Color(0xFF8B7CF6),
      Color(0xFFA874F8),
      Color(0xFFC86EF9),
      Color(0xFFF093FB),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filtrlash",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          SizedBox(height: 15.h),

          Text(
            "Mahsulot kategoriyasi",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 15.h),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(filters.length, (index) {

              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });

                  widget.onSelected(filters[index]);

                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? gradient : null,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: const Color(0xFF6A85F1),
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6A85F1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 30.h)
        ],
      ),
    );
  }
}