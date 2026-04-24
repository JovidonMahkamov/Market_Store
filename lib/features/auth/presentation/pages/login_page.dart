import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../widgets/elevated_wg.dart';
import '../widgets/gradient_background_wg.dart';
import '../widgets/text_field_wg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  bool eye = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      body:
      GradientBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 141),
                   Text(
                    'Tizimga kirish',
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
                    'Biz bilan sayohatingizni davom ettiring.',
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
                            const Text(
                              'Elektron pochta manzilingiz',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2050),
                                letterSpacing: 0.6,
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
                            const Text(
                              'Parolingizni kiriting',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2050),
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFieldWidgetBoard(
                              controller: _passwordController,
                              prefixIcon: Icon(IconlyLight.lock),
                              text: '•••••••••••••',
                              obscureText: eye,
                              keyboardType: TextInputType.visiblePassword,
                              textCapitalization: TextCapitalization.none,
                              suffixIcon: IconButton(
                                icon: Icon(eye ? IconlyLight.hide : IconlyLight.show),
                                onPressed: () => setState(() => eye = !eye),
                              ),
                              readOnly: false,
                            ),
                             SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: (){
                                  Navigator.pushNamed(context, RouteNames.forgotPassword);
                                }, child: Text("Parolni unutdingizmi?",style: TextStyle(color: AppColors.blue, fontSize: 14.sp))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ElevatedWidget(
                              onPressed: (){
                                Navigator.pushNamed(context, RouteNames.bottomNavBar);
                              },
                              text: "Tasdiqlash",
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B6480),
                        ),
                        children: [
                          const TextSpan(text: "Hali akkauntingiz yo‘qmi?  "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, RouteNames.register);
                              },
                              child: const Text(
                                'Ro‘yxatdan o‘ting',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }
}
