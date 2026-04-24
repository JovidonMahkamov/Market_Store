import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../widgets/gradient_background_wg.dart';
import '../widgets/login_link_wg.dart';
import '../widgets/register_form_wg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_agreedToTerms) {
      Flushbar(
        message: "Iltimos, foydalanish shartlariga rozilik bildiring",
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      ).show(context);
      return;
    }
    Navigator.pushNamed(
      context,
      RouteNames.sendOtp,
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 141),
               Text(
                'Hisobingizni yarating',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGrey,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sayohatingizni biz bilan boshlang.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B6480),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              RegisterFormWidget(
                emailController: _emailController,
                agreedToTerms: _agreedToTerms,
                onSubmit: _handleSubmit,
                onToggleTerms: () =>
                    setState(() => _agreedToTerms = !_agreedToTerms),
              ),
              const SizedBox(height: 32),
              LoginLinkWidget(
                text: "Allaqachon akkauntingiz bormi?  ",
                text1: 'Tizimga kirish',
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.login);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
