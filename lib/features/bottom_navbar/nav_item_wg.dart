import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';

class BottomNavItem extends StatelessWidget {
  final bool isSelected;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const LinearGradient _gradient = LinearGradient(
    colors: [
      Color(0xFF6A85F1),
      Color(0xFF8B7CF6),
      Color(0xFFA874F8),
      Color(0xFFC86EF9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color _inactive = AppColors.white;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEAE6FF)
                      :  AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 22,
                  height: 22,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B8CF7),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}