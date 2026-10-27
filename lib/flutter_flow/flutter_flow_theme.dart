import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primary;
  late Color primaryDark;
  late Color primaryAccent;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late TextStyle displayLarge;
  late TextStyle displayMedium;
  late TextStyle displaySmall;
  late TextStyle headlineLarge;
  late TextStyle headlineMedium;
  late TextStyle headlineSmall;
  late TextStyle titleLarge;
  late TextStyle titleMedium;
  late TextStyle titleSmall;
  late TextStyle labelLarge;
  late TextStyle labelMedium;
  late TextStyle labelSmall;
  late TextStyle bodyLarge;
  late TextStyle bodyMedium;
  late TextStyle bodySmall;
}

class LightModeTheme extends FlutterFlowTheme {
  // Brand colors extracted from sample screenshots & MBK logo
  @override
  Color primary = const Color(0xFF0A1C6A); // Deep Royal Navy (Header & Main CTAs)
  @override
  Color primaryDark = const Color(0xFF07134B); // Dark Navy Depth
  @override
  Color primaryAccent = const Color(0xFF1E5BF8); // Electric Royal Blue (Active Badges, Links)
  @override
  Color secondary = const Color(0xFF2563EB); // Vibrant Blue
  @override
  Color tertiary = const Color(0xFFEEF4FF); // Soft Ice-Blue Pill Surface
  @override
  Color alternate = const Color(0xFFF1F5F9); // Light Divider / Input Border
  @override
  Color primaryText = const Color(0xFF0F172A); // High Contrast Slate
  @override
  Color secondaryText = const Color(0xFF64748B); // Muted Label Slate
  @override
  Color primaryBackground = const Color(0xFFF8FAFC); // Clean Canvas Gray
  @override
  Color secondaryBackground = const Color(0xFFFFFFFF); // Crisp Card White
  @override
  Color accent1 = const Color(0x331E5BF8);
  @override
  Color accent2 = const Color(0x332563EB);
  @override
  Color accent3 = const Color(0xFFE2E8F0);
  @override
  Color accent4 = const Color(0xFF94A3B8);
  @override
  Color success = const Color(0xFF22C55E); // Green Badge & Checkmarks
  @override
  Color warning = const Color(0xFFF59E0B);
  @override
  Color error = const Color(0xFFEF4444); // Red Failures & Account Deletion
  @override
  Color info = const Color(0xFF0284C7);

  @override
  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 32.0,
      );
  @override
  TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 28.0,
      );
  @override
  TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 24.0,
      );
  @override
  TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 22.0,
      );
  @override
  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 20.0,
      );
  @override
  TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
      );
  @override
  TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );
  @override
  TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      );
  @override
  TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
      );
  @override
  TextStyle get labelLarge => GoogleFonts.inter(
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  @override
  TextStyle get labelMedium => GoogleFonts.inter(
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );
  @override
  TextStyle get labelSmall => GoogleFonts.inter(
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
      );
  @override
  TextStyle get bodyLarge => GoogleFonts.inter(
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      );
  @override
  TextStyle get bodyMedium => GoogleFonts.inter(
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 13.0,
      );
  @override
  TextStyle get bodySmall => GoogleFonts.inter(
        color: secondaryText,
        fontWeight: FontWeight.w400,
        fontSize: 12.0,
      );
}

extension TextStyleExt on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily ?? 'Plus Jakarta Sans',
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration ?? this.decoration,
              height: lineHeight,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
            );
}
