import 'package:flutter/material.dart';

/// Shared breakpoints and the maximum readable width used by app screens.
///
/// The frame keeps mobile layouts full width while preventing screens from
/// stretching across ultra-wide desktop displays. Individual screens can use
/// the same breakpoints for switching between compact and expanded layouts.
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double contentMaxWidth = 1280;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
}

class AppResponsiveFrame extends StatelessWidget {
  const AppResponsiveFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, AppBreakpoints.contentMaxWidth)
            : AppBreakpoints.contentMaxWidth;

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
        );
      },
    );
  }
}
