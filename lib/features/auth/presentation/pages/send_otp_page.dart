import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../widgets/elevated_wg.dart';
import '../widgets/gradient_background_wg.dart';

class SendOtpPage extends StatefulWidget {
  final String email;

  const SendOtpPage({super.key, required this.email});

  @override
  State<SendOtpPage> createState() => _SendOtpPageState();
}

class _SendOtpPageState extends State<SendOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _agreedToTerms = false;

  late DateTime _expiresAt;
  Timer? _timer;

  String _otp = "";
  Duration _remaining = Duration.zero;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    _expiresAt = DateTime.now().add(Duration(seconds: 45));

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _syncRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _syncRemaining();

      if (_canResend) {
        timer.cancel();
      }
    });
  }

  void _syncRemaining() {
    final now = DateTime.now();
    final diff = _expiresAt.difference(now);

    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
      _canResend = _remaining == Duration.zero;
    });
  }

  void _resendCode() {
    if (!_canResend) return;

    _otpController.clear();
    setState(() => _otp = "");

    // resend => API chaqiradi
    // context.read<CustomerSendEmailBloc>().add(
    //   CustomerSendEmail(email: widget.email),
    // );
  }

  bool get _isButtonEnabled => _otp.length == 6;

  String get _remainingText {
    final seconds = _remaining.inSeconds;
    if (seconds <= 0) return "0";
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      body: GradientBackground(
        child:
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 141),
                  const Text(
                    'Emailingizni tasdiqlang',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGrey,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tasdiqlash kodi ${widget.email} emailga yuborildi',
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
                              'Elektron pochta manzilingizni tasdiqlang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
        
                            const SizedBox(height: 16),
                            Pinput(
                              controller: _otpController,
                              length: 4,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() => _otp = value),
                              onCompleted: (pin) => setState(() => _otp = pin),
                              defaultPinTheme: PinTheme(
                                width: 83,
                                height: 61,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                decoration: BoxDecoration(color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xffCCCCCC),
                                  ),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 83,
                                height: 61,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xff6A85F1),
                                    width: 1.3,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            const SizedBox(height: 18),
                            ElevatedWidget(
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.createAccount);
                              },
                              text: "Tasdiqlash",
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Pochta manzilingizga kelgan kodni kiriting.",
                              style: TextStyle(fontSize: 14, color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _canResend
                            ? "Tasdiqlash kodini olmadingizmi?"
                            : "Qayta yuborish $_remainingText s",
                        style: TextStyle(fontSize: 14.sp, color: AppColors.darkGrey),
                      ),
                      TextButton(
                        onPressed: _canResend ? _resendCode : null,
                        child: Text(
                          "Qayta yuborish",
                          style: TextStyle(
                            color: _canResend
                                ? AppColors.blue
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

      ),
    );
  }
}
