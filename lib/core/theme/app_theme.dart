import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightSeed = Color(0xFFD4A843);
  static const Color _darkSeed = Color(0xFFFFB800);

  static ThemeData get lightTheme {
    final base = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightSeed,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDFBF5),
      cardColor: Colors.white,
      dividerColor: Colors.amber.withValues(alpha: 0.12),
      extensions: const <ThemeExtension<dynamic>>[
        CustomColorsLight(),
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
        ThemeData.dark()
            .textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.amber.withValues(alpha: 0.16),
      extensions: const <ThemeExtension<dynamic>>[
        CustomColorsDark(),
      ],
    );
  }
}

abstract class CustomColors {
  Color get timerWorkColor;
  Color get timerBreakColor;
  Color get timerLongBreakColor;
  Color get soundWaveColor;
  Color get taskUrgentColor;
  Color get taskMediumColor;
  Color get taskChillColor;
  Color get offlineBannerBg;
  Color get offlineBannerText;

  static CustomColors of(ThemeData theme) {
    final light = theme.extension<CustomColorsLight>();
    if (light != null) return light;
    final dark = theme.extension<CustomColorsDark>();
    if (dark != null) return dark;
    return const CustomColorsLight();
  }
}

class CustomColorsLight extends ThemeExtension<CustomColorsLight>
    implements CustomColors {
  const CustomColorsLight();

  @override
  CustomColorsLight copyWith() => const CustomColorsLight();

  @override
  CustomColorsLight lerp(ThemeExtension<CustomColorsLight>? other, double t) =>
      this;

  @override
  Color get timerWorkColor => const Color(0xFFE86C00);

  @override
  Color get timerBreakColor => const Color(0xFF00A878);

  @override
  Color get timerLongBreakColor => const Color(0xFF6C5CE7);

  @override
  Color get soundWaveColor => const Color(0xFFFFB800);

  @override
  Color get taskUrgentColor => const Color(0xFFE86C00);

  @override
  Color get taskMediumColor => const Color(0xFFF39C12);

  @override
  Color get taskChillColor => const Color(0xFF00A878);

  @override
  Color get offlineBannerBg => const Color(0xFFFFF3CD);

  @override
  Color get offlineBannerText => const Color(0xFF856404);
}

class CustomColorsDark extends ThemeExtension<CustomColorsDark>
    implements CustomColors {
  const CustomColorsDark();

  @override
  CustomColorsDark copyWith() => const CustomColorsDark();

  @override
  CustomColorsDark lerp(ThemeExtension<CustomColorsDark>? other, double t) =>
      this;

  @override
  Color get timerWorkColor => const Color(0xFFFF9F43);

  @override
  Color get timerBreakColor => const Color(0xFF4ECDC4);

  @override
  Color get timerLongBreakColor => const Color(0xFFA29BFE);

  @override
  Color get soundWaveColor => const Color(0xFFFFD93D);

  @override
  Color get taskUrgentColor => const Color(0xFFFF6B6B);

  @override
  Color get taskMediumColor => const Color(0xFFFFD93D);

  @override
  Color get taskChillColor => const Color(0xFF4ECDC4);

  @override
  Color get offlineBannerBg => const Color(0xFF3D3D1A);

  @override
  Color get offlineBannerText => const Color(0xFFFFD93D);
}

extension CustomColorsX on ThemeData {
  CustomColorsLight get customLight => extension<CustomColorsLight>()!;
  CustomColorsDark get customDark => extension<CustomColorsDark>()!;
}
