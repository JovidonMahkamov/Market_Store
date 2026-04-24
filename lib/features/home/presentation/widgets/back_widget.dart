import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class BackWidget extends StatelessWidget {
  const BackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.backButton,
      ),
      backgroundColor: AppColors.white,
    );
  }
}
