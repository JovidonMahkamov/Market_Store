import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/widgets/switch_widget.dart';

class ToggleRowWidget extends StatelessWidget {
  final String label;
  final String statusText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRowWidget({
    super.key,
    required this.label,
    required this.statusText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: value ? AppColors.blue : Colors.grey,
            ),
          ),
          SizedBox(width: 8.w),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
