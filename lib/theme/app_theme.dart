import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF121212);
  static const grey = Color(0xFF8C8C8C);
  static const pink = Color(0xFFDE85A0);
  static const pinkDeep = Color(0xFFD06C8B);
  static const pinkSoft = Color(0xFFF6D3DE);
  static const pinkMist = Color(0xFFFDF1F5);
  static const error = Color(0xFFB3261E);
}

class AppFonts {
  static TextStyle display({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.unbounded(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle brand({double size = 30, Color color = AppColors.pinkDeep}) =>
      GoogleFonts.bagelFatOne(fontSize: size, color: color, height: 1);

  static TextStyle body({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.6,
  }) =>
      GoogleFonts.lexendExa(fontSize: size, fontWeight: weight, color: color, height: height);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pinkDeep,
        primary: AppColors.pinkDeep,
        surface: Colors.white,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: Colors.white,
    );

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: GoogleFonts.lexendExaTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.pinkMist,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.pinkDeep, 1.5),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.5),
        prefixIconColor: AppColors.pinkDeep,
        labelStyle: AppFonts.body(color: AppColors.grey),
        floatingLabelStyle: AppFonts.body(color: AppColors.pinkDeep, weight: FontWeight.w600),
        hintStyle: AppFonts.body(color: AppColors.grey.withValues(alpha: 0.7)),
        errorStyle: AppFonts.body(size: 11, color: AppColors.error, height: 1.3),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        contentTextStyle: AppFonts.body(color: Colors.white, weight: FontWeight.w500),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.pinkDeep),
    );
  }
}
