import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff1877f2),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xffe9edf5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff1877f2),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
);
