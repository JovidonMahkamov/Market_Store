import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/terms_bottom_sheet.dart';
import '../../../home/presentation/widgets/back_widget.dart';
import '../widgets/logout_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _agreedToTerms = false;

  void _openTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TermsBottomSheet(
        onAccept: () => setState(() => _agreedToTerms = !_agreedToTerms),
      ),
    );
  }

  bool _chatNotifications = true;

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF6F6),
      Color(0xFFC5B2FF),
      Color(0xFFC3B0FF),
      Color(0xFFE6C5FF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackWidget(),
            SizedBox(width: 12.w),
            Text(
              "Profilni Tahrirlash",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 40.h),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.volume_off_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xffD0AFFF), Color(0xffC23AF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          label: "Chat bildirishnomalar",
                          trailing: Switch(
                            value: _chatNotifications,
                            onChanged: (v) =>
                                setState(() => _chatNotifications = v),

                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xffC23AF5),

                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xffEEF2F6),

                            trackOutlineColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _SettingsTile(
                          icon: Icons.headphones_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xffD0AFFF), Color(0xffC23AF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          label: "Qo'llab-quvvatlash",
                          onTap: () {},
                        ),
                        SizedBox(height: 14.h),
                        _SettingsTile(
                          icon: Icons.assignment_rounded,
                          gradient: LinearGradient(
                            colors: [Color(0xffD0AFFF), Color(0xffC23AF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          label: "Foydalanish shartlari",
                          onTap: _openTerms,
                        ),
                        SizedBox(height: 14.h),
                        _SettingsTile(
                          icon: Icons.logout_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xffD0AFFF), Color(0xffC23AF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          label: "Profildan chiqish",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const LogoutDialog(),
                            );
                          },
                        ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final void Function()? onTap;
  final bool isDestructive;
  final LinearGradient? gradient;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.gradient,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFFB3B3)
                : const Color(0xFFE0D5FF),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(width: 14.w),

            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.purple,
                  size: 22.sp,
                ),
          ],
        ),
      ),
    );
  }
}
