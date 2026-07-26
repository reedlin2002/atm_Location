import 'package:flutter/material.dart';

abstract final class AppLayout {
  static const double spacing = 8;
  static const double pagePadding = 16;
  static const double wideBreakpoint = 700;
  static const double contentMaxWidth = 720;

  static bool useSideBySide(BoxConstraints constraints) {
    return constraints.maxWidth >= wideBreakpoint ||
        (constraints.maxWidth >= 640 &&
            constraints.maxWidth > constraints.maxHeight * 1.45);
  }
}

abstract final class AppTheme {
  static const seedColor = Color(0xFF006C4C);

  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: colors,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
      ),
    );
  }
}
