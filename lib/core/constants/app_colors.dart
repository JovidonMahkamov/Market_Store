import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand Colors ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF7B5EA7);
  static const Color primaryLight = Color(0xFF9B7EC8);
  static const Color primaryDark = Color(0xFF5A3E85);

  // ─── Accent / Pink ──────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFE07AAC);
  static const Color accentLight = Color(0xFFEFA0C4);
  static const Color accentDark = Color(0xFFC05888);

  // ─── Background Colors ──────────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFFF5F0FC);
  static const Color bgSecondary = Color(0xFFEDE6F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardTransparent = Color(0xCCFFFFFF); // 80% opacity

  // ─── Text Colors ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1025);
  static const Color textSecondary = Color(0xFF6B5F7A);
  static const Color textHint = Color(0xFFADA0BC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF7B5EA7);
  static const Color grey = Color(0xFF898794);
  static const Color darkGrey = Color(0xFF2F3542);
  static const Color blue = Color(0xFF4C69FF);

  // ─── Border / Divider ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2D9F0);
  static const Color borderFocused = Color(0xFF7B5EA7);
  static const Color divider = Color(0xFFEDE6F7);

  // ─── Status Colors ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF82);
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color error = Color(0xFFE05C5C);
  static const Color errorLight = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF5B8DEF);
  static const Color infoLight = Color(0xFFEBF1FD);

  // ─── Button Colors ──────────────────────────────────────────────────────────
  static const Color backButton = Color(0xFF6A85F1);
  static const Color white = Color(0xffFEFEFE);
  static const Color purple = Color(0xffBA90FF);

  // ─── Shadow Colors ──────────────────────────────────────────────────────────
  static const Color shadowPrimary = Color(0x337B5EA7);
  static const Color shadowDark = Color(0x1A1A1025);

  // ─── Overlay ────────────────────────────────────────────────────────────────
  static const Color overlay = Color(0x801A1025);
  static const Color overlayLight = Color(0x33FFFFFF);

  // ─── Gradients ──────────────────────────────────────────────────────────────

  /// Asosiy background gradient (rasmdagi kabi)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB8A0E8), // yuqori — binafsha
      Color(0xFFD4A0C8), // o'rta — pushti-binafsha
      Color(0xFFEAC0D0), // quyi o'ng — och pushti
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Tugma gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [
      Color(0xFF6A85F1),
      Color(0xFF8B7CF6),
      Color(0xFFA874F8),
      Color(0xFFC86EF9),
      Color(0xFFF093FB),
    ],
  );

  /// Shimmer (loading) gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEDE6F7),
      Color(0xFFF5F0FC),
      Color(0xFFEDE6F7),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Card subtle gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F0FC),
    ],
  );

  // ─── Box Shadows ────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadowPrimary,
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: shadowDark,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}