import 'package:flutter/material.dart';

class AppColors {
  static const brandOrange = Color(0xFFFF751F);
  static const brandPink = Color(0xFFFF1FA9);
  static const brandRed = Color(0xFFFF3A3A);
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF171717);
  static const textSecondary = Color(0xFF6B7280);
}

class AppTypography {
  static const fontFamily = 'Inter';
  
  static const h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );
  
  static const h2 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );
}

