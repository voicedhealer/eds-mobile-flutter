import 'package:flutter/material.dart';
import 'constants.dart';

class AppGradients {
  // Gradient Hero (135deg orange → pink → rouge)
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandOrange,
      AppColors.brandPink,
      AppColors.brandRed,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Gradient Bouton (135deg orange → pink)
  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandOrange,
      AppColors.brandPink,
    ],
  );
}

