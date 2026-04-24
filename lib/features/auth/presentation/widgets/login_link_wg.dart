import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LoginLinkWidget extends StatelessWidget {
  final String? text;
  final String text1;
  void Function()? onTap;
   LoginLinkWidget({super.key, this.text, required this.text1, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16,  color: AppColors.darkGrey),
          children: [
             TextSpan(text: text),
            WidgetSpan(
              child: GestureDetector(
                onTap: onTap,
                child:  Text(
                  text1,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}