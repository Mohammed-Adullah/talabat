import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // 🎨 مخطط ألوان الوضع الفاتح كما زودتني
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff206487),
      surfaceTint: Color(0xff206487),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc6e7ff),
      onPrimaryContainer: Color(0xff004c6b),
      secondary: Color(0xff4f616d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd2e5f4),
      onSecondaryContainer: Color(0xff374955),
      tertiary: Color(0xff62597c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe8deff),
      onTertiaryContainer: Color(0xff4a4263),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff181c1f),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787e),
      outlineVariant: Color(0xffc1c7ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      onInverseSurface: Color(0xffffffff),
      inversePrimary: Color(0xff91cef5),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff001e2d),
      primaryFixedDim: Color(0xff91cef5),
      onPrimaryFixedVariant: Color(0xff004c6b),
      secondaryFixed: Color(0xffd2e5f4),
      onSecondaryFixed: Color(0xff0a1e28),
      secondaryFixedDim: Color(0xffb6c9d8),
      onSecondaryFixedVariant: Color(0xff374955),
      tertiaryFixed: Color(0xffe8deff),
      onTertiaryFixed: Color(0xff1e1735),
      tertiaryFixedDim: Color(0xffccc1e9),
      onTertiaryFixedVariant: Color(0xff4a4263),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Almarai', // ✅ خط عربي يدعم RTL
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // ✅ أزرار بتصميم ناعم ومتناسق
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ حقول إدخال بنمط عصري
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        alignLabelWithHint: true,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          // ignore: deprecated_member_use
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 13,
        ),
      ),

      // ✅ تخصيص AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
