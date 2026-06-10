import 'package:flutter/material.dart';

// ============================================================================
//  MOON CALENDAR — DESIGN SYSTEM  ·  "Moonlight on Ink"
//  Grounded in Apple HIG + Google Material 3:
//   • 4/8pt spacing grid (Material grid · HIG layout)
//   • min 48dp touch targets (Material) / 44pt (HIG)
//   • tonal elevation on dark surfaces (Material 3 dark elevation)
//   • semantic color roles + state layers
//   • systematic type scale (Material 3 roles ~ HIG text styles)
//   • WCAG AA contrast for body text
// ============================================================================

/// Spacing scale — strict 4pt base, 8pt rhythm.
class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

/// Corner radius scale.
class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double full = 999;
}

/// Motion tokens (Material easing · HIG "smooth, swift").
class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

// Static consts for non-widget uses (painters, etc.) — mirror the dark scheme.
class AppColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF0E0E16);
  static const surfaceVariant = Color(0xFF17171F);
  static const border = Color(0xFF262631);
  static const primary = Color(0xFFB8B8FF);
  static const primaryDim = Color(0xFF8E8ED8);
  static const accent = Color(0xFF5E5CE6);
  static const accentGlow = Color(0xFF23234A);
  static const textPrimary = Color(0xFFF3F3FA);
  static const textSecondary = Color(0xFFA9A9C0);
  static const textDim = Color(0xFF6E6E88);
  static const moonLight = Color(0xFFE9E9F7);
  static const moonShadow = Color(0xFF06060E);
  static const eventRed = Color(0xFFF0625C);
  static const eventGold = Color(0xFFE7B85A);
  static const eventBlue = Color(0xFF5BA8F0);
  static const eventGreen = Color(0xFF4FC58C);
}

/// Theme-aware color scheme, read in widgets via AppColorScheme.of(context).
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceBright;
  final Color border;
  final Color outlineStrong;
  final Color primary;
  final Color primaryDim;
  final Color accent;
  final Color accentGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDim;
  final Color moonLight;
  final Color moonShadow;
  final Color eventRed;
  final Color eventGold;
  final Color eventBlue;
  final Color eventGreen;
  final Brightness brightness;

  const AppColorScheme._({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceBright,
    required this.border,
    required this.outlineStrong,
    required this.primary,
    required this.primaryDim,
    required this.accent,
    required this.accentGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDim,
    required this.moonLight,
    required this.moonShadow,
    required this.eventRed,
    required this.eventGold,
    required this.eventBlue,
    required this.eventGreen,
    required this.brightness,
  });

  // ── DARK · "Moonlight on Ink" (default) ──────────────────────────────────
  static const dark = AppColorScheme._(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceVariant: Color(0xFF2C2C2E),
    surfaceBright: Color(0xFF2C2C2E),
    border: Color(0xFF38383A),
    outlineStrong: Color(0xFF48484A),
    primary: Color(0xFF0A84FF),
    primaryDim: Color(0xFF409CFF),
    accent: Color(0xFF0A84FF),
    accentGlow: Color(0xFF0E2C4A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF98989F),
    textDim: Color(0xFF636366),
    moonLight: Color(0xFFD6D6DA),
    moonShadow: Color(0xFF0A0A0A),
    eventRed: Color(0xFFFF453A),
    eventGold: Color(0xFFFF9F0A),
    eventBlue: Color(0xFF0A84FF),
    eventGreen: Color(0xFF30D158),
    brightness: Brightness.dark,
  );

  // ── LIGHT · "Daylight" ───────────────────────────────────────────────────
  static const light = AppColorScheme._(
    background: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE9E9EB),
    surfaceBright: Color(0xFFFFFFFF),
    border: Color(0xFFD1D1D6),
    outlineStrong: Color(0xFFC7C7CC),
    primary: Color(0xFF007AFF),
    primaryDim: Color(0xFF0066D6),
    accent: Color(0xFF007AFF),
    accentGlow: Color(0xFFE1EEFF),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF8A8A8E),
    textDim: Color(0xFFAEAEB2),
    moonLight: Color(0xFFC7C7CC),
    moonShadow: Color(0xFF1C1C1E),
    eventRed: Color(0xFFFF3B30),
    eventGold: Color(0xFFFF9500),
    eventBlue: Color(0xFF007AFF),
    eventGreen: Color(0xFF34C759),
    brightness: Brightness.light,
  );

  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }

  bool get isDark => brightness == Brightness.dark;

  /// Chữ/icon trên nền [accent] xanh systemBlue → trắng.
  Color get onAccent => const Color(0xFFFFFFFF);

  /// Bảng màu hệ thống iOS cho phân loại sự kiện (đỏ, cam, xanh, lục, tím, lam nhạt).
  List<Color> get eventColors => isDark
      ? const [
          Color(0xFFFF453A), Color(0xFFFF9F0A), Color(0xFF0A84FF),
          Color(0xFF30D158), Color(0xFFBF5AF2), Color(0xFF64D2FF),
        ]
      : const [
          Color(0xFFFF3B30), Color(0xFFFF9500), Color(0xFF007AFF),
          Color(0xFF34C759), Color(0xFFAF52DE), Color(0xFF5AC8FA),
        ];
}

class AppTheme {
  static ThemeData get dark => _buildTheme(AppColorScheme.dark);
  static ThemeData get light => _buildTheme(AppColorScheme.light);

  static ThemeData _buildTheme(AppColorScheme c) {
    final isLight = c.brightness == Brightness.light;

    final textTheme = TextTheme(
        displayLarge: TextStyle(color: c.textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.1),
        displayMedium: TextStyle(color: c.textPrimary, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 0),
        displaySmall: TextStyle(color: c.textPrimary, fontSize: 24, fontWeight: FontWeight.w300),
        headlineLarge: TextStyle(color: c.textPrimary, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        headlineMedium: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        headlineSmall: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: c.textPrimary, fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: c.textDim, fontSize: 13, height: 1.4),
        labelLarge: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        labelMedium: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme(
        brightness: c.brightness,
        surface: c.background,
        surfaceContainerLowest: c.background,
        surfaceContainerLow: c.surface,
        surfaceContainer: c.surface,
        surfaceContainerHigh: c.surfaceVariant,
        surfaceContainerHighest: c.surfaceBright,
        primary: c.accent,
        onPrimary: c.onAccent,
        secondary: c.primary,
        onSecondary: c.onAccent,
        onSurface: c.textPrimary,
        onSurfaceVariant: c.textSecondary,
        outline: c.border,
        outlineVariant: c.border,
        error: c.eventRed,
        onError: Colors.white,
        primaryContainer: c.accentGlow,
        onPrimaryContainer: c.primary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textDim,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: isLight ? 3 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(c.accent),
          foregroundColor: WidgetStatePropertyAll(c.onAccent),
          overlayColor: WidgetStatePropertyAll(c.onAccent.withValues(alpha: 0.10)),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpace.xxl, vertical: AppSpace.lg)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(c.accent),
          overlayColor: WidgetStatePropertyAll(c.accent.withValues(alpha: 0.10)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(c.primary),
          side: WidgetStatePropertyAll(BorderSide(color: c.border)),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(c.textSecondary),
          overlayColor: WidgetStatePropertyAll(c.primary.withValues(alpha: 0.10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: isLight ? 1 : 0,
        shadowColor: isLight ? c.border.withValues(alpha: 0.6) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: c.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        floatingLabelStyle: TextStyle(color: c.accent),
        hintStyle: TextStyle(color: c.textDim),
        prefixIconColor: c.textDim,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceBright,
        contentTextStyle: TextStyle(color: c.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 0.5, space: 0),
      listTileTheme: ListTileThemeData(
        iconColor: c.primaryDim,
        textColor: c.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? c.accent
            : (isLight ? const Color(0xFFE9E9EB) : const Color(0xFF39393D))),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : Colors.transparent),
        checkColor: WidgetStatePropertyAll(c.onAccent),
        side: BorderSide(color: c.outlineStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.border,
        thumbColor: c.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.border,
        circularTrackColor: c.border,
      ),
    );
  }
}
