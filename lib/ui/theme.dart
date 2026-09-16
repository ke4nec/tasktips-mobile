/// 主题令牌来自设计稿 android-mobile-ui.html 的 :root 块（v0.2）。
library;

import 'package:flutter/material.dart';

class AppColors {
  final Color bg, panel, surface, line, text, muted, brand, brandInk, onBrand,
      brandContainer, brandOutline, danger, dangerContainer, warn,
      warnContainer, purple, purpleContainer, shadow;

  const AppColors({
    required this.bg, required this.panel, required this.surface,
    required this.line, required this.text, required this.muted,
    required this.brand, required this.brandInk, required this.onBrand,
    required this.brandContainer, required this.brandOutline,
    required this.danger, required this.dangerContainer,
    required this.warn, required this.warnContainer,
    required this.purple, required this.purpleContainer, required this.shadow,
  });

  static const light = AppColors(
    bg: Color(0xFFF3F3F3), panel: Color(0xFFFFFFFF), surface: Color(0xFFEDEDED),
    line: Color(0x1A000000), text: Color(0xFF1B1B1B), muted: Color(0xFF5F5F5F),
    brand: Color(0xFF0078D4), brandInk: Color(0xFF0067B6), onBrand: Color(0xFFFFFFFF),
    brandContainer: Color(0xFFE0EFFC), brandOutline: Color(0xFF98BDDC),
    danger: Color(0xFFC42B1C), dangerContainer: Color(0xFFFCE9E7),
    warn: Color(0xFF865400), warnContainer: Color(0xFFFFF0D5),
    purple: Color(0xFF72519C), purpleContainer: Color(0xFFEFE5FA),
    shadow: Color(0x26000000),
  );

  static const dark = AppColors(
    bg: Color(0xFF202020), panel: Color(0xFF2B2B2B), surface: Color(0xFF353535),
    line: Color(0x17FFFFFF), text: Color(0xFFFFFFFF), muted: Color(0xFFB4B4B4),
    brand: Color(0xFF4A9EFF), brandInk: Color(0xFF8FC4FF), onBrand: Color(0xFF062E52),
    brandContainer: Color(0xFF243B54), brandOutline: Color(0xFF547BA4),
    danger: Color(0xFFFF6B5E), dangerContainer: Color(0xFF432825),
    warn: Color(0xFFF4BD73), warnContainer: Color(0xFF443724),
    purple: Color(0xFFD5B7FF), purpleContainer: Color(0xFF3B3247),
    shadow: Color(0x5C000000),
  );
}

AppColors appColors(BuildContext c, Brightness b) =>
    b == Brightness.dark ? AppColors.dark : AppColors.light;

ThemeData buildTheme(Brightness b) {
  final a = b == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: a.brand,
    onPrimary: a.onBrand,
    secondary: a.purple,
    onSecondary: a.onBrand,
    error: a.danger,
    onError: a.onBrand,
    surface: a.panel,
    onSurface: a.text,
    surfaceContainerHighest: a.surface,
    onSurfaceVariant: a.muted,
    outline: a.line,
    primaryContainer: a.brandContainer,
    onPrimaryContainer: a.brandInk,
    errorContainer: a.dangerContainer,
    onErrorContainer: a.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: a.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: a.bg,
      foregroundColor: a.text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: a.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: a.line),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: a.panel,
      hintStyle: TextStyle(color: a.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: a.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: a.line),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: a.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
   snackBarTheme: SnackBarThemeData(backgroundColor: a.surface, contentTextStyle: TextStyle(color: a.text)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: a.brand,
      foregroundColor: a.onBrand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
