import 'package:flutter/material.dart';
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
                builder: (context) => DeleteProfileDialog(),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                IconlyLight.delete,
                size: 18,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}