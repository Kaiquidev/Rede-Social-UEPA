import 'package:flutter/material.dart';

import '../core/widgets/mouse_scroll_wrapper.dart';
import '../core/widgets/virtual_keyboard.dart';
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
      // VirtualKeyboard por fora: recebe os constraints reais da janela
      // MouseScrollWrapper por dentro: não interfere no tamanho do teclado
      builder: (context, child) {
        return VirtualKeyboard(
          child: MouseScrollWrapper(
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}
