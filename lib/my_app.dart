import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/navigation/app_navigator.dart';
import 'core/routes/route_generators.dart';
import 'core/routes/route_names.dart';

class MyApp extends StatefulWidget {

  const MyApp({super.key,});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:  Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: RouteNames.bottomNavBar,
          onGenerateRoute: AppRoute().onGenerateRoute,
        );
      },
    );
  }
}