import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightSeed = Color(0xFFD4A843);
  static const Color _darkSeed = Color(0xFFFFB800);

  static ThemeData get lightTheme {
    final base = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightSeed,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDFBF5),
      cardColor: Colors.white,
      dividerColor: Colors.amber.withValues(alpha: 0.12),
      extensions: const <ThemeExtension<dynamic>>[
        _CustomColorsLight(),
      ],
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkSeed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.amber.withValues(alpha: 0.16),
      extensions: const <ThemeExtension<dynamic>>[
        _CustomColorsDark(),
      ],
    );
  }
}

class _CustomColorsLight extends ThemeExtension<_CustomColorsLight> {
  const _CustomColorsLight();

  @override
  _CustomColorsLight copyWith() => const _CustomColorsLight();

  @override
  _CustomColorsLight lerp(ThemeExtension<_CustomColorsLight>? other, double t) => this;

  Color get timerWorkColor => const Color(0xFFE86C00);
  Color get timerBreakColor => const Color(0xFF00A878);
  Color get timerLongBreakColor => const Color(0xFF6C5CE7);
  Color get soundWaveColor => const Color(0xFFFFB800);
  Color get taskUrgentColor => const Color(0xFFE86C00);
  Color get taskMediumColor => const Color(0xFFF39C12);
  Color get taskChillColor => const Color(0xFF00A878);
  Color get offlineBannerBg => const Color(0xFFFFF3CD);
  Color get offlineBannerText => const Color(0xFF856404);
}

class _CustomColorsDark extends ThemeExtension<_CustomColorsDark> {
  const _CustomColorsDark();

  @override
  _CustomColorsDark copyWith() => const _CustomColorsDark();

  @override
  _CustomColorsDark lerp(ThemeExtension<_CustomColorsDark>? other, double t) => this;

  Color get timerWorkColor => const Color(0xFFFF9F43);
  Color get timerBreakColor => const Color(0xFF4ECDC4);
  Color get timerLongBreakColor => const Color(0xFFA29BFE);
  Color get soundWaveColor => const Color(0xFFFFD93D);
  Color get taskUrgentColor => const Color(0xFFFF6B6B);
  Color get taskMediumColor => const Color(0xFFFFD93D);
  Color get taskChillColor => const Color(0xFF4ECDC4);
  Color get offlineBannerBg => const Color(0xFF3D3D1A);
  Color get offlineBannerText => const Color(0xFFFFD93D);
}

extension CustomColors on ThemeData {
  _CustomColorsLight get customLight => extension<_CustomColorsLight>()!;
  _CustomColorsDark get customDark => extension<_CustomColorsDark>()!;
}