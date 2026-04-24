import 'package:flutter/material.dart';
import 'package:market_store/core/routes/route_names.dart';
import 'package:market_store/features/bottom_navbar/bottom_nav_bar.dart';
import 'package:market_store/features/home/presentation/pages/product_edit_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/forgot_password_otp_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/send_otp_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/notification_page.dart';
import '../../features/home/presentation/pages/product_detail_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';

class AppRoute {
  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case RouteNames.sendOtp:
        final email = routeSettings.arguments as String;
        return MaterialPageRoute(builder: (_) => SendOtpPage(email: email));
      case RouteNames.createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountPage());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case RouteNames.forgotPasswordOtp:
        final email = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordOtpPage(email: email),
        );
      case RouteNames.newPasswordPage:
        return MaterialPageRoute(builder: (_) => const NewPasswordPage());
      case RouteNames.bottomNavBar:
        final index = routeSettings.arguments as int? ?? 0;
        return MaterialPageRoute(builder: (_) =>  BottomNavBarPage(
            initialIndex: index
        ));
       case RouteNames.productDetailPage:
        return MaterialPageRoute(builder: (_) => ProductDetailPage());
      case RouteNames.productEditPage:
        return MaterialPageRoute(builder: (_) => ProductEditPage());
      case RouteNames.notificationPage:
        return MaterialPageRoute(builder: (_) => NotificationPage());
      case RouteNames.settingsPage:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => EditProfilePage());
      default:
        return _errorRoute();
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
