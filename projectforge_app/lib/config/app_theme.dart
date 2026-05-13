import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFA43073);
  static const Color secondaryColor = Color(0xFF6D5E00);
  static const Color tertiaryColor = Color(0xFF7B41B4);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color dangerColor = Color(0xFFBA1A1A);
  static const Color darkColor = Color(0xFF0B1C30);
  static const Color lightColor = Color(0xFFF8F9FF);
  static const Color greyColor = Color(0xFF9E9E9E);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF472B6);
  static const Color onPrimaryContainer = Color(0xFF6D0047);
  static const Color onPrimaryFixedVariant = Color(0xFF85145A);
  static const Color primaryFixed = Color(0xFFFFD8E7);
  static const Color primaryFixedDim = Color(0xFFFFAFD3);

  static const Color secondaryContainer = Color(0xFFFCDF46);
  static const Color onSecondaryContainer = Color(0xFF726200);
  static const Color secondaryFixed = Color(0xFFFFE24C);
  static const Color secondaryFixedDim = Color(0xFFE2C62D);
  static const Color onSecondaryFixed = Color(0xFF211B00);

  static const Color tertiaryContainer = Color(0xFFC084FC);
  static const Color onTertiaryContainer = Color(0xFF500989);
  static const Color tertiaryFixed = Color(0xFFF0DBFF);
  static const Color tertiaryFixedDim = Color(0xFFDDB8FF);

  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF544249);

  static const Color outlineColor = Color(0xFF87717A);
  static const Color outlineVariant = Color(0xFFDAC0C9);

  static const Color inverseSurface = Color(0xFF213145);
  static const Color inversePrimary = Color(0xFFFFAFD3);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightColor,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondaryColor,
          onSecondary: onPrimary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          tertiary: tertiaryColor,
          tertiaryContainer: tertiaryContainer,
          onTertiaryContainer: onTertiaryContainer,
          surface: surfaceColor,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceContainerHighest,
          error: errorColor,
          onError: onPrimary,
          errorContainer: errorContainer,
          outline: outlineColor,
          surfaceTint: primaryColor,
        ),
        fontFamily: 'Lexend',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static Color matchColor(double percentage) {
    if (percentage >= 75) return successColor;
    if (percentage >= 50) return warningColor;
    return dangerColor;
  }

  static Color successProbabilityColor(double percentage) {
    if (percentage >= 70) return successColor;
    if (percentage >= 40) return warningColor;
    return dangerColor;
  }
}
