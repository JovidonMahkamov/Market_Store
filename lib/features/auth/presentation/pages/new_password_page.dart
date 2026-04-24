import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

import '../../../../core/routes/route_names.dart';
import '../widgets/elevated_wg.dart';
import '../widgets/gradient_background_wg.dart';
import '../widgets/text_field_wg.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;

  bool eye = true;
  bool eye1 = true;

  @override
  void initState() {
    super.initState();
    // _phoneController.text = widget.email;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  String? _passwordRuleError(String value) {
    final v = value.trim();

    if (v.isEmpty) return "Parol yarating";
    if (v.length < 8) return "Parol kamida 8 ta belgidan iborat bo‘lishi kerak";

    final hasDigit = RegExp(r'\d').hasMatch(v);
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);

    // faqat raqam bo‘lsa
    if (hasDigit && !hasLetter) return "Harf ham qo‘shing (masalan: a, b, A...)";

    // faqat harf bo‘lsa
    if (hasLetter && !hasDigit) return "Raqam ham qo‘shing (masalan: 1,2,3...)";

    // ikkalasi ham bor — ok
    return null;
  }

  void _validatePassword(String value) {
    _passwordError = _passwordRuleError(value);
  }

  void _validateConfirmPassword(String value) {
    _confirmPasswordError = _passwordRuleError(value);
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnack("Iltimos, barcha maydonlarni to‘ldiring");
      return;
    }

    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    setState(() {});

    if (_passwordError != null || _confirmPasswordError != null) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack("Parollar bir xil emas");
      return;
    }

    // context.read<CustomerRegisterBloc>().add(
    //   CustomerRegister(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text.trim(),
    //     confirm_password: _confirmPasswordController.text.trim(),
    //     name: _nameController.text.trim(),
    //     surname: _surnameController.text.trim(),
    //   ),
    // );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      GradientBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 141.h),
                  const Text(
                    'Yangi parol yarating',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1030),
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                      'Parolingiz kamida 8-ta harf va raqamdan iborat bo’lsin ',
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B6480),
                        height: 1.4,)
                  ),
                  const SizedBox(height: 40),

                  ClipRRect(
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
                            _label("Parol yarating"),
                            const SizedBox(height: 12),
                            TextFieldWidgetBoard(
                              controller: _passwordController,
                              prefixIcon: Icon(IconlyLight.lock),
                              text: "•••••••••••••",
                              obscureText: eye,
                              errorText: _passwordError,
                              keyboardType: TextInputType.visiblePassword,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                setState(() {
                                  _validatePassword(v);
                                });
                              },
                              suffixIcon: IconButton(
                                icon: Icon(eye ? IconlyLight.hide : IconlyLight.show),
                                onPressed: () => setState(() => eye = !eye),
                              ),
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            _label("Parol takrorlang"),
                            const SizedBox(height: 12),
                            TextFieldWidgetBoard(
                              controller: _confirmPasswordController,
                              prefixIcon: Icon(IconlyLight.lock),
                              text: '•••••••••••••',
                              obscureText: eye,
                              errorText: _confirmPasswordError,
                              keyboardType: TextInputType.visiblePassword,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                setState(() {
                                  _validateConfirmPassword(v);
                                });
                              },
                              suffixIcon: IconButton(
                                icon: Icon(eye ? IconlyLight.hide : IconlyLight.show),
                                onPressed: () => setState(() => eye = !eye),
                              ),
                              readOnly: false,
                            ),
                            const SizedBox(height: 18),
                            ElevatedWidget(
                              onPressed: (){
                                Navigator.pushNamed(context, RouteNames.login);
                              },
                              text: "Tasdiqlash",
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: 16.sp)),
    );
  }
}
