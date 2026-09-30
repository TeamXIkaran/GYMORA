import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';


class GymText {
  GymText._();

  static const TextStyle h1 = TextStyle(
    color: GymColors.text,
    fontSize: 30,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.8,
  );

  static const TextStyle h2 = TextStyle(
    color: GymColors.text,
    fontSize: 23,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    color: GymColors.text,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle title = TextStyle(
    color: GymColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: GymColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    color: GymColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
  );
}