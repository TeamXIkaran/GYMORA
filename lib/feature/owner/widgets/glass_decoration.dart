import 'package:flutter/material.dart';

/// Standard glass-morphism BoxDecoration used across owner screens.
BoxDecoration glassDecoration({double radius = 18}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.035),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
  );
}
