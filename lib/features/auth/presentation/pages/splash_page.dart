import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/routes/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<InternetConnectionStatus>? _internetSub;

  bool _hasNavigated = false;
  bool _snackShown = false;

  final InternetConnectionChecker _checker = InternetConnectionChecker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialCheck();
      _listenNetworkChanges();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _internetSub?.cancel();
    super.dispose();
  }

  Future<void> _initialCheck() async {
    final hasInternet = await _checker.hasConnection;
    if (!mounted) return;

    if (hasInternet) {
      await _navigateToNextPage();
    } else {
      _showNoInternetSnackBar();
    }
  }

  void _listenNetworkChanges() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) async {
          if (!mounted || _hasNavigated) return;

          final hasAnyNetwork =
              results.isNotEmpty && !results.contains(ConnectivityResult.none);

          if (!hasAnyNetwork) {
            _showNoInternetSnackBar();
            return;
          }

          final hasInternet = await _checker.hasConnection;
          if (!mounted || _hasNavigated) return;

          if (hasInternet) {
            await _navigateToNextPage();
          } else {
            _showNoInternetSnackBar();
          }
        });

    _internetSub = _checker.onStatusChange.listen((status) async {
      if (!mounted || _hasNavigated) return;

      if (status == InternetConnectionStatus.connected) {
        await _navigateToNextPage();
      } else {
        _showNoInternetSnackBar();
      }
    });
  }

  void _showNoInternetSnackBar() {
    if (!mounted || _snackShown) return;
    _snackShown = true;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Internet mavjud emas. Iltimos, tarmoqni yoqing!"),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _snackShown = false;
    });
  }

  Future<void> _navigateToNextPage() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    await _connectivitySub?.cancel();
    await _internetSub?.cancel();

    await Future.delayed(const Duration(seconds: 2));


      Navigator.pushReplacementNamed(context, RouteNames.register);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/backround_image/splash_back.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SvgPicture.asset("assets/backround_image/logo.svg"),
          ),
        ],
      ),
    );
  }
}