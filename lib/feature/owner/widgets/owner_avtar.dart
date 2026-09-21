import 'package:flutter/material.dart';

/// Reusable gradient avatar used across dashboard and member screens.
/// Uses red-tone gradient set indexed by [index].
class OwnerAvatar extends StatelessWidget {
  final String initials;
  final int index;
  final double size;
  final bool showShadow;

  const OwnerAvatar({
    super.key,
    required this.initials,
    required this.index,
    this.size = 42,
    this.showShadow = false,
  });

  static const List<List<Color>> gradients = [
    [Color(0xFFE52A50), Color(0xFF671022)],
    [Color(0xFFB91D3D), Color(0xFF49101C)],
    [Color(0xFFE94C69), Color(0xFF7D1830)],
    [Color(0xFF8D2941), Color(0xFF3B0D19)],
    [Color(0xFFD83355), Color(0xFF651125)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = gradients[index % gradients.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.18),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.27,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
