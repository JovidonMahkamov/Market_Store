import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../widgets/elevated_wg.dart';
import '../widgets/gradient_background_wg.dart';
import '../widgets/text_field_wg.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
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
                  SizedBox(height: 20.h,),
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back_ios)),
                  const SizedBox(height: 141),
                   Text(
                    'Parolni unutdingizmi?',
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
                    'Emailingizga 4 - xonali kod yuboriladi.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B6480),
                      height: 1.4,
                    ),
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
                             Text(
                              'Elektron pochta manzilingiz',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFieldWidgetBoard(
                              controller: _emailController,
                              prefixIcon: Icon(IconlyLight.message),
                              text: 'sizning@gmail.com',
                              obscureText: false,
                              readOnly: false,
                              height: 60,
                            ),
                            const SizedBox(height: 18),
                            ElevatedWidget(
                              onPressed: (){
                                Navigator.pushNamed(context, RouteNames.forgotPasswordOtp,arguments: _emailController.text.trim());
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
}
