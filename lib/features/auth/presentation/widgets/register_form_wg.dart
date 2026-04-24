import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:market_store/features/auth/presentation/widgets/terms_bottom_sheet.dart';
import 'package:market_store/features/auth/presentation/widgets/text_field_wg.dart';
import '../../../../core/constants/app_colors.dart';
import 'elevated_wg.dart';

class RegisterFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final bool agreedToTerms;
  final VoidCallback onSubmit;
  final VoidCallback onToggleTerms;

  const RegisterFormWidget({
    super.key,
    required this.emailController,
    required this.agreedToTerms,
    required this.onSubmit,
    required this.onToggleTerms,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.70),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elektron pochta manzilingiz',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              TextFieldWidgetBoard(
                prefixIcon: Icon(IconlyLight.message),
                controller: emailController,
                text: 'sizning@gmail.com',
                obscureText: false,
                readOnly: false,
                height: 60,
              ),
              const SizedBox(height: 18),
              ElevatedWidget(
                onPressed: onSubmit,
                text: "Tasdiqlash",
                textColor: Colors.white,
              ),
              const SizedBox(height: 20),
              _TermsRow(
                agreedToTerms: agreedToTerms,
                onToggle: onToggleTerms,
                onOpenTerms: () => _openTerms(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTerms(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TermsBottomSheet(
        onAccept: onToggleTerms,
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool agreedToTerms;
  final VoidCallback onToggle;
  final VoidCallback onOpenTerms;

  const _TermsRow({
    required this.agreedToTerms,
    required this.onToggle,
    required this.onOpenTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: agreedToTerms ? onToggle : onOpenTerms,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: agreedToTerms
                  ? const Color(0xFF7B52D8)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: agreedToTerms
                    ? const Color(0xFF7B52D8)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: agreedToTerms
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.45,
              ),
              children: [
                const TextSpan(
                  text: 'Men Foydalanish shartlari va Maxfiylik siyosatiga roziman. ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onOpenTerms,
                    child: const Text(
                      'Foydalanish shartlari.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B52D8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}