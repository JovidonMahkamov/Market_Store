import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  static const Color _inactive = Color(0xFFB0ADCC);

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: isSelected
                    ? BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.circular(20),
                )
                    : const BoxDecoration(),
                child: SvgPicture.asset(
                  icon,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : _inactive,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        _gradient.createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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