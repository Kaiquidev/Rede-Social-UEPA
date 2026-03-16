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
      // Envolve toda a navegação com scroll por botão esquerdo
      // e teclado virtual
      builder: (context, child) {
        return MouseScrollWrapper(
          child: VirtualKeyboard(
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}
