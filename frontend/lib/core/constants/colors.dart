import 'package:flutter/material.dart';

/// Design tokens warna untuk aplikasi.
/// Kelompok: Core, Brand, Neutral (grayscale), Accent/Support, Semantic (status), Surfaces/FX.
/// Catatan: `white` di sini adalah off-white/ivory (bukan #FFFFFF). Pakai `pureWhite` untuk putih murni.
class AppColors {
  // ===== Core ===============================================================
  static const Color black      = Color(0xFF000000);
  static const Color black87       = Color(0xFF121212);
  static const Color black54       = Color(0x8A000000); // 54% black
  static const Color black38       = Color(0x61000000); // 38
  static const Color black12       = Color(0x1F000000); // 12% black
  /// Off-white / ivory. Untuk putih murni gunakan [pureWhite].
  static const Color white      = Color(0xFFFFFBEA);
  static const Color pureWhite  = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ===== Brand / Primary ====================================================
  static const Color primaryRed    = Color(0xFF990100);
  static const Color primaryBlue   = Color(0xFF2D5FB5);
  static const Color primaryGreen  = Color(0xFF4CAF50);
  static const Color primaryYellow = Color(0xFFFFD968);

  // ===== Neutral (Grayscale scale) ==========================================
  // Nama mengikuti skala umum (50 = paling terang … 900 = paling gelap).
  static const Color neutral50  = Color(0xFFF5F5F5); // ~ backgroundGray
  static const Color neutral100 = Color(0xFFE0E0E0); // ~ dividerGray
  static const Color neutral300 = Color(0xFFD1D5DB); // ~ lightGray
  static const Color neutral400 = Color(0xFFA6A6A6); // ~ mediumGray
  static const Color neutral500 = Color(0xFF9E9E9E); // ~ mutedGray
  static const Color neutral800 = Color(0xFF2E2E3A); // ~ darkGray

  // ===== Accent / Support ===================================================
  static const Color lightBlue         = Color(0xFF70ABD8);
  static const Color darkBlue          = Color(0xFF1D395E);
  static const Color accentBlue        = Color(0xFF2051AC); // juga dipakai utk gradient start
  static const Color gradientLightBlue = Color(0xFF6DA9E4);
  static const Color deepPurple        = Color(0xFF673AB7);
  static const Color teal              = Color(0xFF009688);
  static const Color vibrantOrange     = Color(0xFFFF5722);
  static const Color pastelPink        = Color(0xFFFFC1E3);
  static const Color infoBlue          = Color(0xFF2196F3);
  static const Color linkBlue          = Color(0xFF1E88E5);

  // ===== Semantic (Status) ==================================================
  static const Color errorRed    = Color(0xFFFF4C4C);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color successGreen  = primaryGreen; // alias status → brand

  // ===== Surfaces & FX ======================================================
  static const Color backgroundGray  = neutral50;
  static const Color cardBackground  = pureWhite;
  static const Color dividerGray     = neutral100;
  static const Color shadowColor     = Color(0x1A000000); // 10% black
  static const Color semiTransparentBlack = Color(0x80000000); // 50% black
  static const Color semiTransparentWhite = Color(0x80FFFFFF); // 50% white

  // ===== Gradients (tokens) =================================================
  // Gunakan [accentBlue] + [gradientLightBlue] sebagai pasangan gradient.
  static const Color gradientBlue = accentBlue; // alias agar kompatibel

  // ===== Aliases / Backward-compat (Deprecated) =============================
  @Deprecated('Use neutral800')
  static const Color darkGray = neutral800;

  @Deprecated('Use neutral400')
  static const Color mediumGray = neutral400;

  @Deprecated('Use neutral300')
  static const Color lightGrayDeprecated = neutral300; // hindari bentrok nama

  @Deprecated('Use neutral500')
  static const Color mutedGray = neutral500;

  @Deprecated('Use neutral100')
  static const Color dividerGrayDeprecated = neutral100; // hindari bentrok nama

  @Deprecated('Use neutral50')
  static const Color backgroundGrayDeprecated = neutral50; // hindari bentrok nama

  @Deprecated('Use primaryGreen')
  static const Color green = primaryGreen;

  static get primaryBlueGrey => null;
}
