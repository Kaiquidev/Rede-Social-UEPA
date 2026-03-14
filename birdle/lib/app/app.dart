import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class UepaApp extends StatelessWidget {
  const UepaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UEPA Social',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
